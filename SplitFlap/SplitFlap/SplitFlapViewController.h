//
//  ViewController.h
//  SplitFlap
//
//  Created by Adam Preble on 4/18/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SplitFlapClient;

@interface SplitFlapViewController : UIViewController {
	SplitFlapClient *mClient;
	NSTimer *mHeartbeatTimer;
}
@property (strong, nonatomic) IBOutlet UILabel *bigLabel;

@end
