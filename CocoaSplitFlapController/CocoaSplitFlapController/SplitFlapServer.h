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
@class SFDevice;

@interface SplitFlapServer : NSObject {
	ZMQServer *mServer;
	NSMutableDictionary *mDevices;
	NSTimer *mDeviceTimeoutTimer;
}
@property (nonatomic, weak) id<SplitFlapServerDelegate> delegate;
@property (nonatomic, readonly) NSArray *devices;

- (void)displayString:(NSString *)str;
- (void)displayCharacter:(NSString *)str device:(SFDevice *)device;

- (void)beepDevice:(SFDevice *)device;
- (void)startDevicesListening;
- (void)stopDevicesListening;

@end


@protocol SplitFlapServerDelegate <NSObject>

- (void)splitFlapServerDevicesChanged:(SplitFlapServer *)controller;
- (void)splitFlapServer:(SplitFlapServer *)server device:(SFDevice *)device reportedValue:(CGFloat)value;
- (void)splitFlapServer:(SplitFlapServer *)server deviceTapped:(SFDevice *)device;

@end
