//
//  AppDelegate.h
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SplitFlapServer;
@class SFDevice;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	SplitFlapServer *mServer;
	void (^mReportingBlock)(SFDevice *device, CGFloat value);
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSString *displayText;
@property (nonatomic, strong) NSString *statusText;

- (IBAction)startListening:(id)sender;
- (IBAction)stopListening:(id)sender;

@end
