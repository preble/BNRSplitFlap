//
//  SplitFlapDevice.h
//  CocoaSplitFlapController
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDevice : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSDate *lastHeartbeat;
@property (nonatomic, strong) NSString *lastCharacter;

+ (SFDevice *)device;

@end
