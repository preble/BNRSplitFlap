//
//  Flap.h
//  SplitFlap
//
//  Created by Adam Preble on 4/19/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Flap : NSObject {
	GLfloat mAngle;
	BOOL mInMotion;
}

@property (nonatomic, strong) NSString *front; // draw top half of this character on the front
@property (nonatomic, strong) NSString *back; // draw bottom half of this character on the back
@property (nonatomic, readonly) NSUInteger ticksAtRest;
@property (nonatomic, assign) BOOL hidden;

- (void)reset; // reset this flap to be upright and ready to fall
- (void)tick;
- (void)trip; // release this flap to start moving

- (void)drawOpenGL;

@end
