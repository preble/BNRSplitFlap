//
//  SplitFlapController.h
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZMQServer;
@protocol SplitFlapServerDelegate;

@interface SplitFlapServer : NSObject {
	ZMQServer *mServer;
	NSMutableDictionary *mDevices;
	NSTimer *mDeviceTimeoutTimer;
}
@property (nonatomic, weak) id<SplitFlapServerDelegate> delegate;
@property (nonatomic, readonly) NSArray *devices;

- (void)displayString:(NSString *)str;

@end


@protocol SplitFlapServerDelegate <NSObject>

- (void)splitFlapServerDevicesChanged:(SplitFlapServer *)controller;

@end
