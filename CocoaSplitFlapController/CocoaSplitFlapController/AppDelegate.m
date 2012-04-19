//
//  AppDelegate.m
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "AppDelegate.h"
#import "ZMQServer.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	
	__weak AppDelegate *weakSelf = self;
	
	mServer = [[ZMQServer alloc] init];
	mServer.commandBlock = ^ (NSDictionary *cmd) {
		return [weakSelf handleCommand:cmd];
	};
	[mServer startOnBasePort:15780];
}

- (NSDictionary *)handleCommand:(NSDictionary *)cmd
{
	NSString *cmdName = [cmd objectForKey:@"command"];
	NSLog(@"Received command: %@", cmdName);
	if ([cmdName isEqualToString:@"hello"])
	{
		NSString *clientID = @"abcd1234";
		
		return [NSDictionary dictionaryWithObjectsAndKeys:
				clientID, @"id",
				nil];
	}
	else if ([cmdName isEqualToString:@"tap"])
	{
		NSString *clientID = [cmd objectForKey:@"id"];
		NSLog(@"got tap from %@", clientID);
	}
	else if ([cmdName isEqualToString:@"beat"])
	{
		NSString *clientID = [cmd objectForKey:@"id"];
		NSLog(@"got beat from %@", clientID);
	}
	else
	{
		NSLog(@"Received unknown command: %@", cmd);
	}
	return [NSDictionary dictionary];
}

@end
