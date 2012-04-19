//
//  ViewController.h
//  SplitFlap
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <GLKit/GLKit.h>

@class SplitFlapClient;
@class Digit;

@interface SplitFlapViewController : GLKViewController {
	SplitFlapClient *mClient;
	NSTimer *mHeartbeatTimer;
	Digit *mDigit;
}

@end
