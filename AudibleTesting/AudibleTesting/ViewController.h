//
//  ViewController.h
//  AudibleTesting
//
//  Created by Andrew on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"

@interface ViewController : UIViewController{
    AudioController *audioController;
    NSTimer *audioUpdateTimer;
}

@property (nonatomic, weak) IBOutlet UILabel *dbLabel;
@property (nonatomic, weak) IBOutlet UILabel *diffLabel;

- (IBAction)playSound:(id)sender;
- (IBAction)micSwitch:(id)sender;
- (IBAction)resetPeak:(id)sender;
- (void)audioUpdateTimerCallback;

@end
