//
//  SplitFlapDevice.h
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PingResponse;
@class SplitFlapServer;

@interface SFDevice : NSObject {
    NSMutableArray *pingResponses;
}

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSDate *lastHeartbeat;
@property (nonatomic, strong) NSString *lastCharacter;
@property (nonatomic, weak) SplitFlapServer *server;
@property (nonatomic, readonly) NSArray *pingResponses;

+ (SFDevice *)device;
- (PingResponse *)pingResponseFor:(NSString *)deviceId;
- (void)addPingResult:(PingResponse *)response;
- (int)discretePingFor:(NSString *)deviceId;
- (float)rawPingFor:(NSString *)deviceId;
- (SFDevice *)closerDevice:(SFDevice *)device1 orDevice:(SFDevice *)device2;

- (NSArray *)sortPingResponsesByRaw;
- (NSArray *)sortPingResponsesByDiscrete;

- (NSMutableArray *)discreteOnes;
- (NSMutableArray *)followDiscretesWithPath:(NSMutableArray *)path andCompletionSize:(int)completion;

@end
