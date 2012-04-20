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


- (void)beginDiscoveryWithDevice:(SFDevice *)beepDevice valueBlock:(void (^)(SFDevice *device, CGFloat value))block
{
	mReportingBlock = [block copy];
	
	[mServer displayCharacter:@"." device:beepDevice];
	unichar ch = 'A';
	for (SFDevice *device in mServer.devices)
	{
		if (device == beepDevice)
			continue;
		
		[mServer displayCharacter:[NSString stringWithFormat:@"%c", ch]
						   device:device];
		ch++;
	}
	
	[mServer startDevicesListening];
	
	double delayInSeconds = 1.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		
		[mServer beepDevice:beepDevice];
		
		double delayInSeconds = 1.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			
			[mServer stopDevicesListening];
			
			double delayInSeconds = 1.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				
				mReportingBlock(nil, 0);
				mReportingBlock = nil;
			
			});
			
		});
	});
}


- (IBAction)startListening:(id)sender
{
	SFDevice *device = [[mServer devices] objectAtIndex:0];
	[self beginDiscoveryWithDevice:device valueBlock:^(SFDevice *device, CGFloat value) {
		
		if (device)
			NSLog(@"Got reading from device: %0.3f", value);
		else
			NSLog(@"timeout -- all done");
		
	}];
}

- (IBAction)stopListening:(id)sender
{
}


#pragma mark - SplitFlapServerDelegate

- (void)splitFlapServerDevicesChanged:(SplitFlapServer *)controller
{
	[self updateStatusText];
}

- (void)splitFlapServer:(SplitFlapServer *)server device:(SFDevice *)device reportedValue:(CGFloat)value
{
	if (mReportingBlock)
		mReportingBlock(device, value);
}

- (void)splitFlapServer:(SplitFlapServer *)server deviceTapped:(SFDevice *)device
{
	NSLog(@"Starting discovery with device %@", device);
	
	NSMutableDictionary *readings = [NSMutableDictionary dictionary];
	
	[self beginDiscoveryWithDevice:device valueBlock:^(SFDevice *device, CGFloat value) {
		
		if (device)
		{
			NSLog(@"Got reading from %@: %0.3f", device, value);
			[readings setObject:device
						 forKey:[NSNumber numberWithFloat:value]];
		}
		else
		{
			NSLog(@"timeout -- all done");
			unichar ch = '1';
			NSArray *sortedKeys = [[readings allKeys] sortedArrayUsingSelector:@selector(compare:)];
			for (id key in [sortedKeys reverseObjectEnumerator]) // reverse because we want to go from high to low
			{
				SFDevice *device = [readings objectForKey:key];
				[mServer displayCharacter:[NSString stringWithFormat:@"%c", ch++]
								   device:device];
			}
		}
		
	}];
}

@end
