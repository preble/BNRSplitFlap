//
//  AppDelegate.m
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "AppDelegate.h"
#import "SplitFlapServer.h"

@interface AppDelegate () <SplitFlapServerDelegate>
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize displayText = mDisplayText;
@synthesize statusText = mStatusText;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	mServer = [[SplitFlapServer alloc] init];
	mServer.delegate = self;
	[self updateStatusText];
}

- (void)setDisplayText:(NSString *)displayText
{
	mDisplayText = displayText;
	[mServer displayString:mDisplayText];
}

- (void)updateStatusText
{
	self.statusText = [NSString stringWithFormat:@"%d devices", [[mServer devices] count]];
}

#pragma mark - SplitFlapServerDelegate

- (void)splitFlapServerDevicesChanged:(SplitFlapServer *)controller
{
	[self updateStatusText];
}

@end
