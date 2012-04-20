//
//  ViewController.m
//  SplitFlap
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "SplitFlapViewController.h"
#import "SplitFlapClient.h"
#import "Digit.h"
#import "AudioController.h"

@interface SplitFlapViewController () <SplitFlapClientDelegate>

@end


@implementation SplitFlapViewController

- (id)init
{
	self = [super init];
	if (self)
	{
		self.preferredFramesPerSecond = 30;
		EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		GLKView *view = [[GLKView alloc] initWithFrame:CGRectZero context:context];
		self.view = view;
		
		mDigit = [[Digit alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[mHeartbeatTimer invalidate];
	[mAudioUpdateTimer invalidate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
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
	
	[UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	mLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
	mLabel.font = [UIFont systemFontOfSize:24];
	mLabel.backgroundColor = [UIColor clearColor];
	mLabel.textColor = [UIColor grayColor];
	mLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	mLabel.text = @"";
	[self.view addSubview:mLabel];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)tap:(UITapGestureRecognizer *)tap
{
	NSLog(@"tap!");
	[mClient tap];
//	[mDigit random];
}

- (void)heartbeat:(NSTimer *)timer
{
	[mClient heartbeat];
}

- (void)setString:(NSString *)str
{
	[mDigit setCharacter:str animated:YES];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	glClearColor(0.3, 0.3, 0.3, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	[mDigit drawOpenGL];
	
	[mDigit tick];
}

- (AudioController *)audioController
{
	if (!mAudioController)
	{
		mAudioController = [[AudioController alloc] init];
		[mAudioController setSound:[[NSBundle mainBundle] pathForResource :@"440" ofType :@"wav"]];
	}
	return mAudioController;
}

- (void)audioUpdateTimer:(NSTimer *)timer
{
	[[self audioController] updateLevels];
	mLabel.text = [NSString stringWithFormat:@"%0.3f", [[self audioController] peak]];
}

#pragma mark SplitFlapClientDelegate

- (void)splitFlapClientConnected:(SplitFlapClient *)client
{
	[self setString:@" "];
	mHeartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(heartbeat:) userInfo:nil repeats:YES];
}

- (void)splitFlapClientDisconnected:(SplitFlapClient *)client
{
	[self setString:@"X"];
	[mHeartbeatTimer invalidate];
}

- (void)splitFlapClient:(SplitFlapClient *)client displayText:(NSString *)text
{
	[self setString:text];
}

- (void)splitFlapClientBeep:(SplitFlapClient *)client
{
    [[self audioController] playSound];
}

- (void)splitFlapClientStartListening:(SplitFlapClient *)client
{
	[[self audioController] resetPeak];
	[[self audioController] resetDifference];
	[[self audioController] listen];
	
	mAudioUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(audioUpdateTimer:) userInfo:nil repeats:YES];
}

- (CGFloat)splitFlapClientStopListening:(SplitFlapClient *)client
{
	[[self audioController] stop];
	
	[mAudioUpdateTimer invalidate];
	mAudioUpdateTimer = nil;
	
	return [[self audioController] peak];
}

@end
