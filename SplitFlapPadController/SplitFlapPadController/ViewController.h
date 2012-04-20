//
//  ViewController.h
//  SplitFlapPadController
//
//  Created by Adam Preble on 4/20/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SplitFlapServer;

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate> {
	UIPopoverController *mImagePickerPopover;
	SplitFlapServer *mServer;
	NSArray *mColors;
}
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)camera:(id)sender;
- (IBAction)colors:(id)sender;
- (IBAction)randomText:(id)sender;

@end
