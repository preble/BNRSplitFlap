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

@property (strong, nonatomic) IBOutlet UITextField *textBankA;
@property (strong, nonatomic) IBOutlet UITextField *textBankB;
@property (strong, nonatomic) IBOutlet UITextField *textBankC;
@property (strong, nonatomic) IBOutlet UITextField *textBankD;

- (IBAction)sendA:(id)sender;
- (IBAction)sendB:(id)sender;
- (IBAction)sendC:(id)sender;
- (IBAction)sendD:(id)sender;

- (IBAction)camera:(id)sender;
- (IBAction)colors:(id)sender;
- (IBAction)randomText:(id)sender;

- (void)saveTextBanks;

@end
