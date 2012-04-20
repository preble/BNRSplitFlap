//
//  ZMQClient.h
//  SplitFlap
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <czmq.h>

@interface ZMQClient : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
	void (^mResponseBlock)(NSDictionary *resp, NSError *);
	dispatch_queue_t mReqQueue;
	dispatch_queue_t mSubQueue;
	zctx_t *mReqContext;
	zctx_t *mSubContext;
	void *mReqSocket;
	void *mSubSocket;
	BOOL mRunning;
	
	NSNetServiceBrowser *mNetServiceBrowser;
	NSNetService *mChosenService;
	
	void (^mConnectedBlock)(NSError *);
}

@property (nonatomic, copy) void (^commandBlock)(NSDictionary *command);

- (void)connectViaBonjourWithCompletionBlock:(void (^)(NSError *error))block;
- (BOOL)connectToHost:(NSString *)host basePort:(NSUInteger)basePort;

- (BOOL)sendToServer:(NSDictionary *)plist response:(void (^)(NSDictionary *resp, NSError *error))responseBlock;

@end

