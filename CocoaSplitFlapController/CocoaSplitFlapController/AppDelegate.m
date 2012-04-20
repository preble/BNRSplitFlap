//
//  AppDelegate.m
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "AppDelegate.h"
#import "SplitFlapServer.h"
#import "SFDevice.h"
#import "PingResponse.h"

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
				
				void (^block)(SFDevice *device, CGFloat value) = mReportingBlock;
				mReportingBlock = nil;
				
				block(nil, 0);
			});
			
		});
	});
}


- (IBAction)startListening:(id)sender
{
	NSMutableDictionary *results = [NSMutableDictionary dictionary];
	NSMutableArray *devices = [[mServer devices] mutableCopy];
	
	__block void (^block)();
	block = ^{
		
		if (devices.count > 0)
		{
			SFDevice *beepDevice = [devices objectAtIndex:0];
			[devices removeObjectAtIndex:0];
			
			NSMutableDictionary *deviceResults = [NSMutableDictionary dictionary];
			[self beginDiscoveryWithDevice:beepDevice valueBlock:^(SFDevice *resultDevice, CGFloat value) {
				if (resultDevice == nil)
				{
					[results setObject:deviceResults forKey:beepDevice.identifier];
					block();
				}
				else
				{
					[deviceResults setObject:[NSNumber numberWithFloat:value]
									  forKey:resultDevice.identifier];
				}
			}];
		}
		else
		{
            
            
			NSLog(@"Results:");
			for (NSString *beepId in results)
			{
				NSDictionary *deviceResults = [results objectForKey:beepId];
				NSLog(@"  %@ beep results:", beepId);
				for (NSString *receiverId in deviceResults)
				{
					CGFloat value = [[deviceResults objectForKey:receiverId] floatValue];
					NSLog(@"    %@   %0.3f", receiverId, value);
				}
                
			}
            
            // sort device results by lowest
            // make discrete
            // add to SFDevice
            // loop through devices
            // create comparisons
            
            for(int idx=0; idx < [[mServer devices] count]; idx++){
                SFDevice *currentDevice = [[mServer devices] objectAtIndex:idx];
                // get result reports and set PingResponse
                NSDictionary *deviceResults = [results objectForKey:currentDevice.identifier];
				for (NSString *receiverId in deviceResults){
                    
                    PingResponse *response = [[PingResponse alloc] init];
                    [response setBroadcastId:currentDevice.identifier];
                    [response setReceiverId:receiverId];
                    
                    CGFloat value = [[deviceResults objectForKey:receiverId] floatValue];
                    [response setRaw:value];
                    
                    [[mServer deviceForId:receiverId] addPingResult:response];
                }
            }
            
            
            
            // Set the discrete values for all of our ping responses:
            for(int idx=0; idx < [[mServer devices] count]; idx++){
                SFDevice *currentDevice = [[mServer devices] objectAtIndex:idx];
                
                NSArray *sortedByRaw = [currentDevice sortPingResponsesByRaw];
                if([sortedByRaw count]>0){
                    float currentRaw = [[sortedByRaw objectAtIndex:0] raw];
                    int currentDiscrete = 1;
                    for (PingResponse *pr in sortedByRaw)
                    {
                        if (fabsf(currentRaw - pr.raw) > 2.0)
                        {
                            currentDiscrete++;
                            currentRaw = pr.raw;
                        }
                        pr.discrete = currentDiscrete;
                    }
                }
            }
            
            for(int idx=0; idx < [[mServer devices] count]; idx++){
                SFDevice *currentDevice = [[mServer devices] objectAtIndex:idx];
                

                // new way using graph theory, courtesy of Galvin
                NSMutableArray *possibleOrder = [currentDevice followDiscretesWithPath:nil andCompletionSize:[[mServer devices] count]];                
                if(possibleOrder)
                    NSLog(@">>> possible order %@",possibleOrder);
                else
                    NSLog(@">>> no path from this device");

                /*
                 // old way using weird algorithm
                 // sort based on discretes
                int currentDiscrete = 0;
                NSMutableArray *sortedByDiscrete = [[currentDevice sortPingResponsesByDiscrete] mutableCopy];
                NSLog(@"sortedByDiscrete: %@",sortedByDiscrete);
                

                [possibleOrder addObject:currentDevice];
                while([sortedByDiscrete count] > 1){
                    NSLog(@"working order: %@",possibleOrder);
                    
                    SFDevice *firstDiscrete = [mServer deviceForId:[[sortedByDiscrete objectAtIndex:currentDiscrete] broadcastId]];
                    SFDevice *secondDiscrete = [mServer deviceForId:[[sortedByDiscrete objectAtIndex:currentDiscrete+1] broadcastId]];
                    SFDevice *closerDevice = [currentDevice closerDevice:firstDiscrete orDevice:secondDiscrete];
                    
//                    NSLog(@"first: %@",firstDiscrete);
//                    NSLog(@"second: %@",secondDiscrete);
//                    NSLog(@"closer: %@",closerDevice);
                    
                    if(closerDevice){
                        // one is closer
                        [possibleOrder addObject:closerDevice];
                        [sortedByDiscrete removeObject:[currentDevice pingResponseFor:closerDevice.identifier]];
                    }else{
                        // both are closest, put it in the middle
//                        int idx = [possibleOrder indexOfObject:currentDevice];
                        [possibleOrder insertObject:firstDiscrete atIndex:0];
                        [sortedByDiscrete removeObjectAtIndex:currentDiscrete];
                    }
                    currentDiscrete++;
                }
                
                SFDevice *lastDiscrete = [mServer deviceForId:[[sortedByDiscrete objectAtIndex:[sortedByDiscrete count]-1] broadcastId]];
                [possibleOrder addObject:lastDiscrete];
                */
                
                
                

            }
		}
	};
	
	block = [block copy];
	block();
}

- (IBAction)stopListening:(id)sender
{
}


#pragma mark - Sort code




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
            // add reading to 
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
        
        // do some sorting?
        
		
	}];
}

@end
