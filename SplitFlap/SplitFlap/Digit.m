//
//  Digit.m
//  SplitFlap
//
//  Created by Adam Preble on 4/19/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "Digit.h"
#import "Flap.h"
#import "BitmapFont.h"

@implementation Digit

@synthesize flaps = mFlaps;

- (id)init
{
    self = [super init];
    if (self) {
        mCharacters = [[[BitmapFont standardFont] characters] sortedArrayUsingSelector:@selector(compare:)];
//		mCharacters = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", nil];
		NSMutableArray *flaps = [NSMutableArray array];
		NSString *lastChStr = [mCharacters lastObject];
		for (NSString *chStr in mCharacters)
		{
			Flap *flap = [[Flap alloc] init];
			flap.back = chStr;
			flap.front = lastChStr;
			[flaps addObject:flap];
			lastChStr = chStr;
			
			[flap reset];
		}
		[[mFlaps objectAtIndex:0] setHidden:YES];
		mFlaps = flaps;
		mTopCharacterIndex = 0;
		mTicksUntilNextTrip = NSUIntegerMax;
		
		[self setCharacter:@"L" animated:YES];
    }
    return self;
}

- (NSString *)currentCharacter
{
	Flap *flap = [mFlaps objectAtIndex:mTopCharacterIndex];
	return [flap front];
}

- (void)setCharacter:(NSString *)str animated:(BOOL)animate
{
	if ([mCharacters containsObject:str] == NO)
	{
		NSLog(@"Asked to display unknown character: \"%@\"", str);
		return;
	}
	mDesiredCharacter = str;
	if ([str isEqualToString:[self currentCharacter]])
		mTicksUntilNextTrip = NSUIntegerMax;
	else if (mTicksUntilNextTrip > 1000)
		mTicksUntilNextTrip = 1; // 1 because it will be decremented next tick
}

- (void)tick
{
	NSUInteger count = [mCharacters count];
	mTicksUntilNextTrip--;
	if (mTicksUntilNextTrip == 0)
	{
		Flap *flap = [mFlaps objectAtIndex:mTopCharacterIndex];
		[flap trip];
		mTopCharacterIndex = ((mTopCharacterIndex + 1) % count);
		[[mFlaps objectAtIndex:mTopCharacterIndex] reset]; // prepare it to be tripped next
		if ([[self currentCharacter] isEqualToString:mDesiredCharacter])
			mTicksUntilNextTrip = NSUIntegerMax;
		else
			mTicksUntilNextTrip = 3;
	}
	for (Flap *flap in mFlaps)
		[flap tick];
	
	for (Flap *flap in mFlaps)
	{
		// Newly at rest.  Hide anybody who is more at rest.
		if (flap.ticksAtRest == 1)
		{
			for (Flap *other in mFlaps)
			{
				if (other.ticksAtRest > flap.ticksAtRest)
					other.hidden = YES;
			}
		}
	}
}

- (void)random
{
	[self setCharacter:[mCharacters objectAtIndex:random() % [mCharacters count]] animated:YES];
}

- (void)drawOpenGL
{
	glEnable(GL_TEXTURE_2D);
	
	for (Flap *flap in self.flaps)
	{
		[flap drawOpenGL];
	}
}

@end
