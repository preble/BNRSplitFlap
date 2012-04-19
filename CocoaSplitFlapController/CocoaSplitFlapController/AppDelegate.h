//
//  AppDelegate.h
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ZMQServer;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	ZMQServer *mServer;
}

@property (assign) IBOutlet NSWindow *window;

@end
