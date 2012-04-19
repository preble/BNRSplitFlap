//
//  ViewController.m
//  AudibleTesting
//
//  Created by Andrew on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize dbLabel, diffLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    audioController = [[AudioController alloc] init];
    audioUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                        target:self
                                                      selector: @selector(audioUpdateTimerCallback)
                                                      userInfo: nil
                                                       repeats: YES];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return UIDeviceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - IBActions

- (IBAction)micSwitch:(id)sender{
    UISwitch *micStatus = (UISwitch *)sender;
    if([micStatus isOn]){
        [audioController listen];
        audioUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                            target:self
                                                          selector: @selector(audioUpdateTimerCallback)
                                                          userInfo: nil
                                                           repeats: YES];
    }else {
        [audioUpdateTimer invalidate];
        audioUpdateTimer = nil;
        [audioController stop];
    }
}

- (IBAction)resetPeak:(id)sender{
    [audioController resetPeak];
    [audioController resetDifference];
}

- (IBAction)playSound:(id)sender{
    //    NSString *path  = [[NSBundle mainBundle] pathForResource : fName ofType :ext];
    [audioController setSound:[[NSBundle mainBundle] pathForResource :@"impact" ofType :@"wav"]];
    [audioController playSound];
}

#pragma mark - Audio timer

- (void)audioUpdateTimerCallback{
    [audioController updateLevels];
    [dbLabel setText:[NSString stringWithFormat:@"%.2f",[audioController peak]]];
    [diffLabel setText:[NSString stringWithFormat:@"%.2f",[audioController difference]]];
}

@end
