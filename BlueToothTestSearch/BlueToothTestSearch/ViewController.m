//
//  ViewController.m
//  BlueToothTestSearch
//
//  Created by Andrew on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize bluetoothManager, bluetoothSwitch, deviceTable, scanButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
     bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark - Bluetooth methods

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */

- (BOOL) isLECapableHardware
{
    NSString *message;
    BOOL isCapable = NO;
    
    switch (bluetoothManager.state) {
        case CBCentralManagerStateUnknown:
            message=[NSString stringWithFormat:@"State unknown, update imminent."];
            break;
        case CBCentralManagerStateResetting:
            message=[NSString stringWithFormat:@"The connection with the system service was momentarily lost, update imminent."];
            break;
        case CBCentralManagerStateUnsupported:
            message=[NSString stringWithFormat:@"The platform doesn't support Bluetooth Low Energy"];
            break;
        case CBCentralManagerStateUnauthorized:
            message=[NSString stringWithFormat:@"The app is not authorized to use Bluetooth Low Energy"];
            break;
        case CBCentralManagerStatePoweredOff:
            message=[NSString stringWithFormat:@"Bluetooth is currently powered off."];
            break;
        case CBCentralManagerStatePoweredOn:
            message=[NSString stringWithFormat:@"Bluetooth is currently powered on and available to use."];
            isCapable = YES;
            break;
    }
    NSLog(@"%@",message);
    return isCapable;
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"device discovered");
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[advertisementData description]]);
}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 */

-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    NSLog(@"This is it!");
    
    NSLog(@"Retrieved peripherals: %i - %@", [peripherals count], peripherals);
    
    [self stopScan];
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central{ 
    [self isLECapableHardware];
} 

/*
 Request CBCentralManager to stop scanning for heart rate peripherals
 */
- (void) stopScan 
{
    [bluetoothManager stopScan];
}


- (void)toggleBluetooth:(id)sender{
//    Class BluetoothManager = objc_getClass( "BluetoothManager" );
//    id btCont = [BluetoothManager sharedInstance];
//    [self performSelector:@selector(toggle:) withObject:btCont afterDelay:0.1f];
}

- (IBAction)scanForDevices:(id)sender{
    if([self isLECapableHardware]){
        [bluetoothManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:DEVICE_INFO]] options:nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return UIDeviceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - UITableView methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

@end
