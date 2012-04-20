//
//  ZMQServer.h
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <czmq.h>

@interface ZMQServer : NSObject <NSNetServiceDelegate> {
	dispatch_queue_t mRepQueue;
	dispatch_queue_t mPubQueue;
	zctx_t *mRepContext;
	zctx_t *mPubContext;
	void *mRepSocket;
	void *mPubSocket;
	BOOL mRunning;
	
	NSNetService *mNetService;
}

@property (nonatomic, copy) NSDictionary *(^commandBlock)(NSDictionary *command);

- (BOOL)startOnBasePort:(NSUInteger)basePort;
- (void)publishCommand:(NSDictionary *)plist;

@end
