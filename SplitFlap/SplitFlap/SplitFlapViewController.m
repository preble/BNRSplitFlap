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
		view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
		self.view = view;
		
		mDigit = [[Digit alloc] init];
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
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glEnable(GL_DEPTH_TEST);
	
	[mDigit drawOpenGL];
	
	[mDigit tick];
}

#pragma mark SplitFlapClientDelegate

- (void)splitFlapClientConnected:(SplitFlapClient *)client
{
	[self setString:@"!"];
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

@end
