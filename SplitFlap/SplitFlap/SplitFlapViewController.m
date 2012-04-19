//
//  ViewController.m
//  SplitFlap
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "SplitFlapViewController.h"
#import "SplitFlapClient.h"

@interface SplitFlapViewController () <SplitFlapClientDelegate>

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
	}
	return self;
}

- (void)dealloc
{
	[mHeartbeatTimer invalidate];
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
	
	mClient = [[SplitFlapClient alloc] init];
	mClient.delegate = self;
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
	[self.view addGestureRecognizer:tap];
}

- (void)tap:(UITapGestureRecognizer *)tap
{
	NSLog(@"tap!");
	[mClient tap];
}

- (void)heartbeat:(NSTimer *)timer
{
	[mClient heartbeat];
}

#pragma mark SplitFlapClientDelegate

- (void)splitFlapClientConnected:(SplitFlapClient *)client
{
	self.bigLabel.text = @" ";
	mHeartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(heartbeat:) userInfo:nil repeats:YES];
}

- (void)splitFlapClientDisconnected:(SplitFlapClient *)client
{
	self.bigLabel.text = @"ಠ";
	[mHeartbeatTimer invalidate];
}

- (void)splitFlapClient:(SplitFlapClient *)client displayText:(NSString *)text
{
	self.bigLabel.text = text;
}

@end
