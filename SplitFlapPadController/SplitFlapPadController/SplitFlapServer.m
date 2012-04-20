//
//  SplitFlapController.m
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "SplitFlapServer.h"
#import "ZMQServer.h"
#import "SFDevice.h"

@implementation SplitFlapServer

@synthesize delegate = mDelegate;

- (id)init
{
    self = [super init];
    if (self)
	{
		mDevices = [[NSMutableDictionary alloc] init];
		
		__weak SplitFlapServer *weakSelf = self;
        mServer = [[ZMQServer alloc] init];
		mServer.commandBlock = ^(NSDictionary *cmd) {
			return [weakSelf handleClientCommand:cmd];
		};
		[mServer startOnBasePort:15780];
		
		mDeviceTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(deviceTimeout:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc
{
	[mDeviceTimeoutTimer invalidate];
}

#pragma mark - Helpers

- (NSDictionary *)handleClientCommand:(NSDictionary *)cmd
{
	SFDevice *device;
	NSString *cmdName = [cmd objectForKey:@"command"];
	NSString *devId = [cmd objectForKey:@"id"];
	
	if (devId)
		device = [self deviceForIdentifier:devId];
	
	if ([cmdName isEqualToString:@"hello"])
	{
		if (!device)
		{
			device = [self createDeviceWithIdentifier:devId];
		}
		[self touchDevice:device];
		
		NSLog(@"New device: %@", device);
		
		return [NSDictionary dictionaryWithObjectsAndKeys:
				device.identifier, @"id",
				nil];
	}
	else if ([cmdName isEqualToString:@"tap"])
	{
		NSLog(@"got tap from %@", device);
		[mDelegate splitFlapServer:self deviceTapped:device];
	}
	else if ([cmdName isEqualToString:@"beat"])
	{
//		NSLog(@"got heartbeat from %@", device ?: @"(unknown device)");
		[self touchDevice:device];
		return [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithBool:(device != nil)], @"ok",
				nil];
	}
	else if ([cmdName isEqualToString:@"report"])
	{
		CGFloat value = [[cmd objectForKey:@"value"] floatValue];
		// We got 'value' from 'device'.
		[mDelegate splitFlapServer:self device:device reportedValue:value];
	}
	else
	{
		NSLog(@"Received unknown command: %@", cmd);
	}
	return [NSDictionary dictionary];
}

- (void)notifyDevicesChanged
{
	[mDelegate splitFlapServerDevicesChanged:self];
}

- (SFDevice *)deviceForIdentifier:(NSString *)identifier
{
	return [mDevices objectForKey:identifier];
}

- (SFDevice *)createDeviceWithIdentifier:(NSString *)identifier
{
	SFDevice *device = [SFDevice device];
	device.identifier = identifier;
	[mDevices setObject:device forKey:identifier];
	[self notifyDevicesChanged];
	return device;
}

- (void)touchDevice:(SFDevice *)device
{
	device.lastHeartbeat = [NSDate date];
}

- (void)deviceTimeout:(NSTimer *)timer
{
	BOOL removedAny = NO;
	NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:-5];
	for (SFDevice *device in [self devices])
	{
		if ([device.lastHeartbeat compare:timeout] == NSOrderedAscending)
		{
			[mDevices removeObjectForKey:device.identifier];
			NSLog(@"Device %@ timed out.", device);
			removedAny = YES;
		}
	}
	if (removedAny)
		[self notifyDevicesChanged];
}

- (void)displayCharacter:(NSString *)str device:(SFDevice *)device
{
	// Tell a single device to change.  Ordinarily this is done with all devices all at once.
	device.lastCharacter = str;
	[mServer publishCommand:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"display", @"command",
							 [NSDictionary dictionaryWithObjectsAndKeys:
							  str, device.identifier, nil], @"devices",
							 nil]];
}

- (void)beepDevice:(SFDevice *)device
{
	[mServer publishCommand:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"beep", @"command",
							 device.identifier, @"id",
							 nil]];
}

- (void)startDevicesListening
{
	[mServer publishCommand:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"listen", @"command",
							 nil]];
}

- (void)stopDevicesListening
{
	[mServer publishCommand:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"report", @"command",
							 nil]];
	// Devices will now send in their reports.
}

#pragma mark - Public API

- (void)displayString:(NSString *)str
{
	str = [str uppercaseString];
	
	NSArray *devices = [self orderedDevices];
	NSMutableDictionary *deviceChars = [NSMutableDictionary dictionary];
	for (NSUInteger index = 0; index < [devices count]; index++)
	{
		unichar ch = ' ';
		if (index < str.length)
			ch = [str characterAtIndex:index];
		SFDevice *device = [devices objectAtIndex:index];
		NSString *str = [NSString stringWithFormat:@"%c", ch];
		device.lastCharacter = str;
		[deviceChars setObject:str forKey:device.identifier];
	}
	[mServer publishCommand:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"display", @"command",
							 deviceChars, @"devices",
							 nil]];
}

- (void)displayColors:(NSArray *)colors
{
	int colorIndex = 0;
	NSArray *devices = [self orderedDevices];
	NSMutableDictionary *deviceChars = [NSMutableDictionary dictionary];
	for (SFDevice *device in devices)
	{
		if (colorIndex >= [colors count])
		{
			NSLog(@"out of colors");
			break;
		}
		UIColor *color = [colors objectAtIndex:colorIndex++];
		CGFloat r, g, b, a;
		[color getRed:&r green:&g blue:&b alpha:&a];
		device.color = color;
		NSDictionary *components = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithFloat:r], @"r",
									[NSNumber numberWithFloat:g], @"g",
									[NSNumber numberWithFloat:b], @"b",
									nil];
		[deviceChars setObject:components forKey:device.identifier];
	}
	[mServer publishCommand:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"color", @"command",
							 deviceChars, @"devices",
							 nil]];
}

- (NSArray *)devices
{
	return [mDevices allValues];
}

- (NSArray *)orderedDevices
{
	if (mOrderedDevices)
		return mOrderedDevices;
	else
		return [mDevices allValues];
}

- (void)setOrderedDevices:(NSArray *)orderedDevices
{
	mOrderedDevices = orderedDevices;
}

@end
