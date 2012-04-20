//
//  PingResponse.h
//  CocoaSplitFlapController
//
//  Created by Andrew on 4/20/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PingResponse : NSObject

@property (nonatomic, strong) NSString *broadcastId;
@property (nonatomic, strong) NSString *receiverId;
@property (nonatomic, assign) float raw;
@property (nonatomic, assign) int discrete;

@end
