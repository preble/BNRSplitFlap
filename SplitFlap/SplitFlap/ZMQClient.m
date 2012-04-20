//
//  ZMQClient.m
//  SplitFlap
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ZMQClient.h"



@interface NSData (ZMQ)
+ (NSData *)dataFromZeroMQMessage:(zmsg_t *)zmsg;
@end



@implementation ZMQClient

@synthesize commandBlock = mCommandBlock;

- (id)init
{
    self = [super init];
    if (self) {
        mReqQueue = dispatch_queue_create("zmq-reqrep", DISPATCH_QUEUE_SERIAL);
        mSubQueue = dispatch_queue_create("zmq-pubsub", DISPATCH_QUEUE_SERIAL);
		dispatch_async(mReqQueue, ^{
			mReqContext = zctx_new();
			mReqSocket = zsocket_new(mReqContext, ZMQ_REQ);
		});
		dispatch_async(mSubQueue, ^{
			mSubContext = zctx_new();
			mSubSocket = zsocket_new(mSubContext, ZMQ_SUB);
		});
    }
    return self;
}

- (void)dealloc
{
	[mNetServiceBrowser setDelegate:nil];
	
	dispatch_sync(mReqQueue, ^{
		zsocket_destroy(mReqContext, mReqSocket);
		zctx_destroy(&mReqContext);
	});
	dispatch_sync(mSubQueue, ^{
		zsocket_destroy(mSubContext, mSubSocket);
		zctx_destroy(&mSubContext);
	});
	dispatch_release(mReqQueue);
	dispatch_release(mSubQueue);
}

- (void)connectViaBonjourWithCompletionBlock:(void (^)(NSError *error))block;
{
	mConnectedBlock = [block copy];
	
	if (mNetServiceBrowser)
		[mNetServiceBrowser setDelegate:nil];
	
	mNetServiceBrowser = [[NSNetServiceBrowser alloc] init];
	[mNetServiceBrowser setDelegate:self];
	[mNetServiceBrowser searchForServicesOfType:@"_splitflap._tcp" inDomain:@""];
}

- (BOOL)connectToHost:(NSString *)host basePort:(NSUInteger)basePort
{
	mRunning = YES;
	dispatch_async(mReqQueue, ^{
		zsocket_connect(mReqSocket, "tcp://%s:%d", [host UTF8String], basePort);
		
	});
	dispatch_async(mSubQueue, ^{
		zsocket_connect(mSubSocket, "tcp://%s:%d", [host UTF8String], basePort+1);
		
		zmq_pollitem_t pollitems[] = { { mSubSocket, 0, ZMQ_POLLIN, 0 } };
		while (mRunning)
		{
			zmq_poll(pollitems, 1, 10 * ZMQ_POLL_MSEC);
			
			if (pollitems[0].revents & ZMQ_POLLIN)
			{
				zmsg_t *msg = zmsg_recv(mSubSocket);
				NSData *data = [NSData dataFromZeroMQMessage:msg];
				
				NSError *err;
				NSDictionary *plist = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
				if (plist)
				{
					if (self.commandBlock)
					{
						dispatch_async(dispatch_get_main_queue(), ^{
							self.commandBlock(plist);
						});
					}
				}
				else {
					NSLog(@"Error deserializing subscribe message: %@", err);
				}
				
				zmsg_destroy(&msg);
			}
		}
	});
	return YES;
}

- (BOOL)sendToServer:(NSDictionary *)plist response:(void (^)(NSDictionary *, NSError *))responseBlock
{
	responseBlock = [responseBlock copy];
	dispatch_async(mReqQueue, ^{
		
		NSError *err;
		NSData *data = [NSJSONSerialization dataWithJSONObject:plist options:0 error:&err];
		if (!data)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, err);
			});
			return;
		}
		zmq_msg_t msg;
		zmq_msg_init_size(&msg, [data length]);
		memcpy(zmq_msg_data(&msg), [data bytes], [data length]);
		zmq_send(mReqSocket, &msg, 0);
		zmq_msg_close(&msg);

		// Wait for a response, but only for 2s:
		zmq_pollitem_t pollitems[] = { { mReqSocket, 0, ZMQ_POLLIN, 0 } };
		zmq_poll(pollitems, 1, 2000 * ZMQ_POLL_MSEC);
		
		if (pollitems[0].revents & ZMQ_POLLIN)
		{
			zmsg_t *reply = zmsg_recv(mReqSocket);
			if (!reply)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, [NSError errorWithDomain:@"ReceiveInterrupted" code:0 userInfo:nil]);
				});
				return;
			}
			NSData *replyData = [NSData dataFromZeroMQMessage:reply];
			NSDictionary *replyPlist = [NSJSONSerialization JSONObjectWithData:replyData options:0 error:&err];

			dispatch_async(dispatch_get_main_queue(), ^{
				if (!replyPlist)
					responseBlock(nil, err);
				else
					responseBlock(replyPlist, nil);
			});

			zmsg_destroy(&reply);
		}
		else
		{
			NSLog(@"Timeout while waiting for response.");
			dispatch_async(dispatch_get_main_queue(), ^{
				NSError *err = [NSError errorWithDomain:@"ZMQTimeout" code:0 userInfo:nil];
				responseBlock(nil, err);
			});
		}
	});
	return YES;
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	if (!mChosenService)
	{
		mChosenService = aNetService;
		[mChosenService setDelegate:self];
		[mChosenService resolveWithTimeout:10.0];
	}
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSString *host = [sender hostName];
	NSInteger port = [sender port];
	
	NSData *data = [[sender addresses] objectAtIndex:0];
	struct sockaddr_storage sockAddr;
	[data getBytes:&sockAddr length:data.length];
	
	char szAddr[256];
	getnameinfo((struct sockaddr*)&sockAddr, data.length, szAddr, 256, 0, 0, NI_NUMERICHOST);
	host = [NSString stringWithUTF8String:szAddr];

	NSLog(@"Resolved host: %@:%d", host, port);
	[self connectToHost:host basePort:port];
	
	mConnectedBlock(nil);
	mConnectedBlock = nil;
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"Failed to resolve net service: %@", errorDict);
}

@end

@implementation NSData (ZMQ)

+ (NSData *)dataFromZeroMQMessage:(zmsg_t *)zmsg
{
	NSMutableData *data = [NSMutableData dataWithCapacity:zmsg_content_size(zmsg)];
	while (zmsg_first(zmsg) != NULL)
	{
		zframe_t *frame = zmsg_pop(zmsg);
		[data appendBytes:zframe_data(frame) length:zframe_size(frame)];
		zframe_destroy(&frame);
	}
	return data;
}
@end
