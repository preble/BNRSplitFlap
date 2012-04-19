//
//  ViewController.m
//  SplitFlap
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "SplitFlapViewController.h"
#import "ZMQClient.h"

@interface SplitFlapViewController ()

@end


@implementation SplitFlapViewController
@synthesize bigLabel;

- (id)init
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    self = [self initWithNibName:@"SplitFlapViewController_iPhone" bundle:nil];
	} else {
	    self = [self initWithNibName:@"SplitFlapViewController_iPad" bundle:nil];
	}
	if (self)
	{
		__weak SplitFlapViewController *weakSelf = self;
		mClient = [[ZMQClient alloc] init];
		mClient.commandBlock = ^ (NSDictionary *command) {
			[weakSelf processCommand:command];
		};
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
	[self setBigLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[mClient connectToHost:@"10.1.10.31" basePort:15780];
	
	NSDictionary *helloCommand = [NSDictionary dictionaryWithObjectsAndKeys:
								  @"hello", @"command",
								  nil];
	[mClient sendToServer:helloCommand response:^(NSDictionary *resp, NSError *error) {
		if (resp)
		{
			mClientID = [resp objectForKey:@"id"];
			NSLog(@"Got ID: %@", mClientID);
		}
		else
		{
			NSLog(@"Error from hello command: %@", error);
		}
	}];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
	[self.view addGestureRecognizer:tap];
}

- (void)processCommand:(NSDictionary *)cmd
{
	NSString *commandName = [cmd objectForKey:@"command"];
	if ([commandName isEqualToString:@"display"])
	{
		NSString *targetID = [cmd objectForKey:@"id"];
		if ([targetID isEqualToString:mClientID])
			self.bigLabel.text = [cmd objectForKey:@"value"];
		else
			NSLog(@"Ignoring display command for id %@", targetID);
	}
	else
	{
		NSLog(@"%s Unrecognized command: %@", __PRETTY_FUNCTION__, cmd);
	}
}

- (void)tap:(UITapGestureRecognizer *)tap
{
	NSLog(@"tap!");
	NSDictionary *cmd = [NSDictionary dictionaryWithObjectsAndKeys:
						 @"tap", @"command",
						 mClientID, @"id",
						 nil];
	[mClient sendToServer:cmd response:^(NSDictionary *resp, NSError *error) {
		// don't care
	}];
}

@end
