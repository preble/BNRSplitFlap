//
//  SplitFlapClient.h
//  SplitFlap
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZMQClient;
@protocol SplitFlapClientDelegate;

@interface SplitFlapClient : NSObject {
	ZMQClient *mClient;
	NSString *mClientID;
	BOOL mWasListening;
}
@property (nonatomic, weak) id<SplitFlapClientDelegate> delegate;

- (void)tap;
- (void)heartbeat;

@end


@protocol SplitFlapClientDelegate <NSObject>

- (void)splitFlapClientConnected:(SplitFlapClient *)client;
- (void)splitFlapClientDisconnected:(SplitFlapClient *)client;

- (void)splitFlapClient:(SplitFlapClient *)client displayText:(NSString *)text;

- (void)splitFlapClientBeep:(SplitFlapClient *)client;
- (void)splitFlapClientStartListening:(SplitFlapClient *)client;
- (CGFloat)splitFlapClientStopListening:(SplitFlapClient *)client;

@end