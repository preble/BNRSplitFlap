//
//  SplitFlapDevice.m
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "SFDevice.h"

NSString *UUIDString(void);


@implementation SFDevice

@synthesize identifier, lastHeartbeat;

+ (SFDevice *)device
{
	return [[SFDevice alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.identifier = UUIDString();
    }
    return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p: %@>", NSStringFromClass([self class]), self, self.identifier];
}

@end



NSString *UUIDString(void)
{
	CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
	NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
	CFRelease(uuidObject);
	return uuidStr;
}
