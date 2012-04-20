//
//  ZMQServer.m
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ZMQServer.h"



@interface NSData (ZMQ)
+ (NSData *)dataFromZeroMQMessage:(zmsg_t *)zmsg;
@end



@implementation ZMQServer

@synthesize commandBlock = mCommandBlock;

- (id)init
{
    self = [super init];
    if (self) {
        mRepQueue = dispatch_queue_create("zmq-reqrep", DISPATCH_QUEUE_SERIAL);
        mPubQueue = dispatch_queue_create("zmq-pubsub", DISPATCH_QUEUE_SERIAL);
		dispatch_async(mRepQueue, ^{
			mRepContext = zctx_new();
			mRepSocket = zsocket_new(mRepContext, ZMQ_REP);
		});
		dispatch_async(mPubQueue, ^{
			mPubContext = zctx_new();
			mPubSocket = zsocket_new(mPubContext, ZMQ_PUB);
		});
    }
    return self;
}

- (void)dealloc
{
	dispatch_sync(mRepQueue, ^{
		zsocket_destroy(mRepContext, mRepQueue);
		zctx_destroy(&mRepContext);
	});
	dispatch_sync(mPubQueue, ^{
		zsocket_destroy(mPubContext, mPubSocket);
		zctx_destroy(&mPubContext);
	});
	dispatch_release(mRepQueue);
	dispatch_release(mPubQueue);
}

- (BOOL)startOnBasePort:(NSUInteger)basePort
{
	NSString *host = @"0.0.0.0";
	mRunning = YES;
	dispatch_async(mRepQueue, ^{
		zsocket_bind(mRepSocket, "tcp://%s:%d", [host UTF8String], basePort);
		zmq_pollitem_t pollitems[] = { { mRepSocket, 0, ZMQ_POLLIN, 0 } };
		while (mRunning)
		{
			zmq_poll(pollitems, 1, 10 * ZMQ_POLL_MSEC);
			
			if (pollitems[0].revents & ZMQ_POLLIN)
			{
				zmsg_t *msg = zmsg_recv(mRepSocket);
				NSData *data = [NSData dataFromZeroMQMessage:msg];
				
				NSError *err;
				NSDictionary *plist = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
				if (plist)
				{
					__block NSDictionary *respDict = [NSDictionary dictionary];
					if (self.commandBlock)
					{
						dispatch_sync(dispatch_get_main_queue(), ^{
							respDict = self.commandBlock(plist);
						});
					}
					
					NSError *err;
					NSData *respData = [NSJSONSerialization dataWithJSONObject:respDict options:0 error:&err];
					if (!respData)
					{
						NSLog(@"Error converting reply to JSON: %@", err);
						return;
					}
					zmq_msg_t respMsg;
					zmq_msg_init_size(&respMsg, [respData length]);
					memcpy(zmq_msg_data(&respMsg), [respData bytes], [respData length]);
					zmq_send(mRepSocket, &respMsg, 0);
					zmq_msg_close(&respMsg);

				}
				else {
					NSLog(@"Error deserializing subscribe message: %@", err);
				}
				
				zmsg_destroy(&msg);
			}
		}
	});
	dispatch_async(mPubQueue, ^{
		zsocket_bind(mPubSocket, "tcp://%s:%d", [host UTF8String], basePort+1);
	});
	
	mNetService = [[NSNetService alloc] initWithDomain:@"" type:@"_splitflap2._tcp" name:@"server" port:basePort];
	[mNetService setDelegate:self];
	[mNetService publish];
	return YES;
}

- (void)publishCommand:(NSDictionary *)plist
{
	NSError *err;
	NSData *data = [NSJSONSerialization dataWithJSONObject:plist options:0 error:&err];
	if (!data)
	{
		NSLog(@"Error converting command to JSON: %@", err);
		return;
	}
	
	dispatch_async(mPubQueue, ^{
		zmq_msg_t msg;
		zmq_msg_init_size(&msg, [data length]);
		memcpy(zmq_msg_data(&msg), [data bytes], [data length]);
		zmq_send(mPubSocket, &msg, 0);
		zmq_msg_close(&msg);
	});
}

#pragma mark - NSNetServiceDelegate

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
	NSLog(@"NSNetService failed to publish: %@", errorDict);
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

