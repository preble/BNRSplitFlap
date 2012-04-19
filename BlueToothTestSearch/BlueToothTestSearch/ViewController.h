//
//  ViewController.h
//  BlueToothTestSearch
//
//  Created by Andrew on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define HEARTRATE @"180D"
#define DEVICE_INFO @"180A"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate>

@property (readwrite, strong) CBCentralManager *bluetoothManager;
@property (nonatomic, weak) IBOutlet UISwitch *bluetoothSwitch;
@property (nonatomic, weak) IBOutlet UITableView *deviceTable;
@property (nonatomic, weak) IBOutlet UIButton *scanButton;

- (IBAction)scanForDevices:(id)sender;
- (void) stopScan;

@end
