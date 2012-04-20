//
//  SplitFlapDevice.m
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "SFDevice.h"
#import "PingResponse.h"
#import "SplitFlapServer.h"

NSString *UUIDString(void);


@implementation SFDevice

@synthesize identifier, lastHeartbeat, lastCharacter, pingResponses, server;

+ (SFDevice *)device
{
	return [[SFDevice alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.identifier = UUIDString();
        pingResponses = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p: %@ \"%@\">", NSStringFromClass([self class]), self, self.identifier, self.lastCharacter];
}


NSString *UUIDString(void)
{
	CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
	NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
	CFRelease(uuidObject);
	return uuidStr;
}

- (void)addPingResult:(PingResponse *)response{
    [pingResponses addObject:response];
    // probably sort them?
}

- (int)discretePingFor:(NSString *)deviceId{
    // TODO what to return if no entry?
    for(PingResponse *response in pingResponses){
        if([[response broadcastId] isEqualToString:deviceId])
            return [response discrete];
    }
    return 0;
}

- (float)rawPingFor:(NSString *)deviceId{
    for(PingResponse *response in pingResponses){
        if([[response broadcastId] isEqualToString:deviceId])
            return [response raw];
    }
    return 0;
}

- (PingResponse *)pingResponseFor:(NSString *)deviceId{
    for(PingResponse *pr in pingResponses){
        if([[pr broadcastId] isEqualToString:deviceId])
            return pr;
    }
    return nil;
}

- (NSArray *)sortPingResponsesByRaw{
    return [pingResponses sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PingResponse *a = obj1;
        PingResponse *b = obj2;
        if (a.raw < b.raw)
            return NSOrderedAscending;
        else if (a.raw > b.raw)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
}

- (NSArray *)sortPingResponsesByDiscrete{
    return [pingResponses sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PingResponse *a = obj1;
        PingResponse *b = obj2;
        if (a.discrete < b.discrete)
            return NSOrderedAscending;
        else if (a.discrete > b.discrete)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
}

- (SFDevice *)closerDevice:(SFDevice *)device1 orDevice:(SFDevice *)device2{
    
    
    // possibly will fail when the discrete from device1 is bad
    int selfdiscrete = [self discretePingFor:device1.identifier];
    int device1discrete = [device1 discretePingFor:self.identifier];
    int device2discrete = [device2 discretePingFor:self.identifier];
    
    if(selfdiscrete == device1discrete && selfdiscrete == device2discrete){
        NSLog(@"closerDevice: none");
        return nil;
    }else if(selfdiscrete == device1discrete){
        if(device2discrete > device1discrete){
            NSLog(@"closerDevice: %@ > %@",device2, device1);
            return device1;
        }
    }else if(selfdiscrete == device2discrete){
        if(device1discrete > device2discrete){
            NSLog(@"closerDevice: %@ > %@",device1, device2);
            return device2;
        }
    }
    
    NSLog(@"closerDevice: Something bad happened, fell through all logic");
    
    return nil;
}

- (NSMutableArray *)discreteOnes{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(PingResponse *response in pingResponses){
        if([response discrete] == 1)
            [array addObject:response];
    }
    return array;
}

- (NSMutableArray *)followDiscretesWithPath:(NSMutableArray *)path andCompletionSize:(int)completion{
    if(!path)
        path = [[NSMutableArray alloc] init];
    
    if([path count]+1 == completion){
        [path addObject:self];
        return path;
    }
    
    NSMutableArray *discreteArray = [self discreteOnes];
    if(discreteArray && [discreteArray count] > 0){
        for(PingResponse *response in [discreteArray copy]){
            for(SFDevice *device in path){
                if([[response broadcastId] isEqualToString:device.identifier]){
                    [discreteArray removeObject:response];
                    break;
                }
            }
        }
        if([discreteArray count] > 0){
            [path addObject:self];
            for(PingResponse *response in discreteArray){
                for(SFDevice *device in [server devices]){
                    if([[response broadcastId] isEqualToString:device.identifier]){
                        NSMutableArray *result = [device followDiscretesWithPath:path andCompletionSize:completion];
                        if(result)
                            return result;
                    }
                }
            }
        }
    }
    return nil;
}


@end
