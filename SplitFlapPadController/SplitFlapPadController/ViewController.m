//
//  ViewController.m
//  SplitFlapPadController
//
//  Created by Adam Preble on 4/20/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "ViewController.h"
#import "SplitFlapServer.h"
#import "SFDevice.h"

@interface ViewController () <SplitFlapServerDelegate>

@end

@implementation ViewController
@synthesize statusLabel;
@synthesize textBankA;
@synthesize textBankB;
@synthesize textBankC;
@synthesize textBankD;

- (void)dealloc
{
	[mClockModeTimer invalidate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
//	NSMutableSet *availableColors = [NSMutableSet setWithObjects:
//									 [UIColor colorWithRed:1 green:1 blue:1 alpha:1],
//									 [UIColor colorWithRed:1 green:0 blue:0 alpha:1],
//									 [UIColor colorWithRed:0 green:1 blue:0 alpha:1],
//									 [UIColor colorWithRed:0 green:0 blue:1 alpha:1],
//									 nil];
//
//	NSArray *orderedColors = [self processImage:[UIImage imageNamed:@"ColorBarsPhoto"] colors:availableColors];
//	NSLog(@"%@", orderedColors);
}

- (void)viewDidUnload
{
	[self setStatusLabel:nil];
	[self setTextBankA:nil];
	[self setTextBankB:nil];
	[self setTextBankC:nil];
	[self setTextBankD:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	mColors = [NSArray arrayWithObjects:
			   [UIColor colorWithRed:1 green:1 blue:1 alpha:1],
			   [UIColor colorWithRed:1 green:0 blue:0 alpha:1],
			   [UIColor colorWithRed:0 green:1 blue:0 alpha:1],
			   [UIColor colorWithRed:0 green:0 blue:1 alpha:1],
			   nil];

	mServer = [[SplitFlapServer alloc] init];
	mServer.delegate = self;
	[self updateStatusText];
	
	[self loadTextBanks];
}


- (void)updateStatusText
{
	self.statusLabel.text = [NSString stringWithFormat:@"%d devices", [[mServer devices] count]];
}

- (void)loadTextBanks
{
	self.textBankA.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"splitflap.textBankA"];
	self.textBankB.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"splitflap.textBankB"];
	self.textBankC.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"splitflap.textBankC"];
	self.textBankD.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"splitflap.textBankD"];
}

- (void)saveTextBanks
{
	[[NSUserDefaults standardUserDefaults] setObject:self.textBankA.text forKey:@"splitflap.textBankA"];
	[[NSUserDefaults standardUserDefaults] setObject:self.textBankB.text forKey:@"splitflap.textBankB"];
	[[NSUserDefaults standardUserDefaults] setObject:self.textBankC.text forKey:@"splitflap.textBankC"];
	[[NSUserDefaults standardUserDefaults] setObject:self.textBankD.text forKey:@"splitflap.textBankD"];
}

- (void)setClockModeOn:(BOOL)run
{
	if (!run && mClockModeTimer)
	{
		[mClockModeTimer invalidate];
		mClockModeTimer = nil;
		return;
	}
	if (run && !mClockModeTimer)
	{
		mClockModeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(clockModeTimer:) userInfo:nil repeats:YES];
	}
}

- (void)clockModeTimer:(NSTimer *)sender
{
	int numDevices = [[mServer orderedDevices] count];
	if (numDevices <= 3)
	{
		// Show number of seconds.
		NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
		int secs = ((int)t) % (int)powf(10, numDevices);
		NSString *str = [NSString stringWithFormat:@"%d", secs];
		[mServer displayString:str];
	}
	else if (numDevices == 4)
	{
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"mmss"];
		[mServer displayString:[df stringFromDate:[NSDate date]]];
	}
	else if (numDevices == 5)
	{
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"mm:ss"];
		[mServer displayString:[df stringFromDate:[NSDate date]]];
	}
	else if (numDevices == 6 || numDevices == 7)
	{
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"HHmmss"];
		[mServer displayString:[df stringFromDate:[NSDate date]]];
	}
	else if (numDevices >= 8)
	{
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"HH:mm:ss"];
		[mServer displayString:[df stringFromDate:[NSDate date]]];
	}
}

#pragma mark - Image Processing

float ColorDistance(UIColor *color, int r, int g, int b)
{
	CGFloat cr, cg, cb, ca;
	[color getRed:&cr green:&cg blue:&cb alpha:&ca];
	
	return fabsf( cr - ((float)r)/255.0) +
	 fabsf( cg - ((float)g)/255.0) +
	fabsf( cb - ((float)b)/255.0);

}

- (NSArray *)processImage:(UIImage *)image colors:(NSArray *)colors
{
	NSMutableArray *orderedColors = [NSMutableArray array];
	const int w = 320;
	const int h = 240;
	const int components = 4;
	const int bytesPerRow = w*components;
	CGContextRef ctx;
	CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
	ctx = CGBitmapContextCreate(NULL, w, h, 8, bytesPerRow, cs, kCGImageAlphaPremultipliedLast);
	
	CGContextDrawImage(ctx, CGRectMake(0, 0, w, h), [image CGImage]);
	
	uint8_t *data = CGBitmapContextGetData(ctx);
	
	UIColor *currentColor = nil;
	
	int y = h/2;
	for (int x = 0; x < w; x++)
	{
		uint8_t *pixel = &data[ y * bytesPerRow + (x * components) ];
		int r = pixel[0];
		int g = pixel[1];
		int b = pixel[2];
		
		float bestDistance = 10000000000;
		UIColor *bestColor = nil;
		for (UIColor *color in colors)
		{
			float d = ColorDistance(color, r, g, b);
			if (d < bestDistance)
			{
				bestDistance = d;
				bestColor = color;
			}
		}
		
		// Ignore it if our best distance is not good:
		if (bestDistance > 0.8)
			continue;
		
		if (bestColor != currentColor)
		{
			currentColor = bestColor;
//			CGFloat r, g, b, a;
//			[currentColor getRed:&r green:&g blue:&b alpha:&a];
//			NSLog(@"x = %d  New color: %0.2f %0.2f %0.2f", x, r, g, b);
			[orderedColors addObject:currentColor];
		}
	}
	
//	CGImageRef imageOut = CGBitmapContextCreateImage(ctx);
//	NSData *pngData = UIImagePNGRepresentation([UIImage imageWithCGImage:imageOut]);
//	[pngData writeToFile:@"/tmp/output.png" atomically:NO];
	
	CGContextRelease(ctx);
	CGColorSpaceRelease(cs);
	
	return orderedColors;
}


- (IBAction)colors:(id)sender
{
	[mServer displayColors:mColors];
}

- (IBAction)randomText:(id)sender
{
	long r = random();
	[mServer displayString:[NSString stringWithFormat:@"%08d", r]];
}

- (IBAction)clockModeToggled:(UISwitch *)sender
{
	[self setClockModeOn:[sender isOn]];
}

- (IBAction)sendA:(id)sender
{
	[mServer displayString:self.textBankA.text];
}
- (IBAction)sendB:(id)sender
{
	[mServer displayString:self.textBankB.text];
}
- (IBAction)sendC:(id)sender
{
	[mServer displayString:self.textBankC.text];
}
- (IBAction)sendD:(id)sender
{
	[mServer displayString:self.textBankD.text];
}

- (IBAction)camera:(id)sender
{
	[mServer displayColors:mColors];
	
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
	ipc.delegate = self;
	ipc.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	
	mImagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:ipc];
	mImagePickerPopover.delegate = self;
	[mImagePickerPopover presentPopoverFromRect:[sender frame]
										 inView:[sender superview]
					   permittedArrowDirections:UIPopoverArrowDirectionAny
									   animated:YES];
}

#pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo 
{
	NSArray *orderedColors = [self processImage:image colors:mColors];
	if (image.imageOrientation == UIImageOrientationDown)
		orderedColors = [[orderedColors reverseObjectEnumerator] allObjects];
	NSLog(@"orderedColors = %@", orderedColors);
	
	NSMutableArray *devices = [[mServer devices] mutableCopy];
	NSMutableArray *orderedDevices = [ NSMutableArray array];
	
	for (UIColor *color in orderedColors)
	{
		// Find the device for this color and add it to the array.
		SFDevice *foundDevice = nil;
		for (SFDevice *device in devices)
		{
			if ([device.color isEqual:color])
			{
				foundDevice = device;
				break;
			}
		}
		if (foundDevice)
		{
			[devices removeObject:foundDevice];
			[orderedDevices addObject:foundDevice];
		}
		else
		{
			NSLog(@"Error: couldn't find device for color: %@", color);
		}
	}
	
	[mServer setOrderedDevices:orderedDevices];
	[mServer displayString:@"123456789"];
	
	[mImagePickerPopover dismissPopoverAnimated:YES];
}


#pragma mark - SplitFlapServerDelegate

- (void)splitFlapServerDevicesChanged:(SplitFlapServer *)controller
{
	[self updateStatusText];
}

- (void)splitFlapServer:(SplitFlapServer *)server device:(SFDevice *)device reportedValue:(CGFloat)value
{
}

- (void)splitFlapServer:(SplitFlapServer *)server deviceTapped:(SFDevice *)device
{
}

@end
