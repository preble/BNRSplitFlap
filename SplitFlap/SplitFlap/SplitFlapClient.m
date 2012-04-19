//
//  SplitFlapClient.m
//  SplitFlap
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "SplitFlapClient.h"
#import "ZMQClient.h"

@implementation SplitFlapClient

@synthesize delegate = mDelegate;

- (id)init
{
    self = [super init];
    if (self)
	{
		__weak SplitFlapClient *weakSelf = self;
		mClient = [[ZMQClient alloc] init];
		mClient.commandBlock = ^ (NSDictionary *command) {
			[weakSelf handleCommandFromServer:command];
		};
		
		[mClient connectToHost:@"10.1.10.31" basePort:15780];
		
		[self startHello];

    }
    return self;
}

- (void)startHello
{
	NSDictionary *helloCommand = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"hello", @"command",
								  nil];
	[mClient sendToServer:helloCommand response:^(NSDictionary *resp, NSError *error) {
		if (resp)
		{
			mClientID = [resp objectForKey:@"id"];
			NSLog(@"Got ID: %@", mClientID);
			[mDelegate splitFlapClientConnected:self];
		}
		else
		{
			NSLog(@"Error from hello command: %@", error);
			// Wait a little while and try again:
			double delayInSeconds = 5.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self startHello];
			});
		}
	}];
}

- (void)handleCommandFromServer:(NSDictionary *)cmd
{
	NSString *commandName = [cmd objectForKey:@"command"];
	if ([commandName isEqualToString:@"display"])
	{
		NSDictionary *deviceChars = [cmd objectForKey:@"devices"];
		NSString *text = [deviceChars objectForKey:mClientID];
		if (text)
			[mDelegate splitFlapClient:self displayText:text];
	}
	else
	{
		NSLog(@"%s Unrecognized command: %@", __PRETTY_FUNCTION__, cmd);
	}
}

- (void)tap
{
	NSDictionary *cmd = [NSDictionary dictionaryWithObjectsAndKeys:
						 @"tap", @"command",
						 mClientID, @"id",
						 nil];
	[mClient sendToServer:cmd response:^(NSDictionary *resp, NSError *error) {
		// don't care
	}];
}

- (void)heartbeat
{
	NSDictionary *cmd = [NSDictionary dictionaryWithObjectsAndKeys:
						 @"beat", @"command",
						 mClientID, @"id",
						 nil];
	[mClient sendToServer:cmd response:^(NSDictionary *resp, NSError *error) {
		if (resp)
		{
			BOOL ok = [[resp objectForKey:@"ok"] boolValue];
			if (!ok)
			{
				// Server must have restarted; need to say hello again.
				NSLog(@"Got unfavorable reply from heartbeat; saying hello again.");
				[self startHello];
			}
		}
		else
		{
			NSLog(@"Bad reply from beat: %@", error);
			[mDelegate splitFlapClientDisconnected:self];
			[self startHello];
		}
	}];
}


@end
