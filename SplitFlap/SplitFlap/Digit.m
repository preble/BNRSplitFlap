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
#import <GLKit/GLKit.h>

@implementation Digit

@synthesize flaps = mFlaps;

- (id)init
{
    self = [super init];
    if (self) {
        mCharacters = [[[BitmapFont standardFont] characters] sortedArrayUsingSelector:@selector(compare:)];
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
			flap.hidden = YES;
		}
		mFlaps = flaps;
		mTopCharacterIndex = 0;
		mTicksUntilNextTrip = NSUIntegerMax;
		
		NSError *err;
		mFlapTexture = [GLKTextureLoader textureWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Flap" withExtension:@"png"]
														  options:nil
															error:&err];
		if (!mFlapTexture)
		{
			NSLog(@"Error loading flap texture: %@", err);
		}

		
		[self setCharacter:@"A" animated:YES];
		
		NSString *audioFile = [[NSBundle mainBundle] pathForResource:@"impact" ofType:@"wav"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:audioFile]){
			NSURL *pathURL = [NSURL fileURLWithPath : audioFile];
			AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &mTripSound);
		}
		else
			NSLog(@"error, file not found: %@", audioFile);

    }
    return self;
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(mTripSound);
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
			mTicksUntilNextTrip = 2;
		
		AudioServicesPlaySystemSound(mTripSound);
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

- (NSArray *)flapsForDrawing
{
	NSMutableArray *output = [NSMutableArray array];
	for (Flap *flap in self.flaps)
	{
		if (flap.hidden == NO)
			[output addObject:flap];
	}
	[output sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		Flap *a = obj1;
		Flap *b = obj2;
		float angleA = fabsf(a.angle - 90);
		float angleB = fabsf(b.angle - 90);
		if (angleA == angleB)
			return NSOrderedSame;
		if (angleA < angleB)
			return NSOrderedDescending;
		else
			return NSOrderedAscending;
	}];
	return output;
}

- (void)drawOpenGL
{	
#if 0
	glEnable(GL_LIGHTING);
	
	float ambient[] = {0.0, 0.0, 0.0, 1.0};
	float diffuse[] = {1.0, 1.0, 1.0, 1.0};
	float specular[] = {0.1, 0.1, 0.1, 1.0};
	float lightPos[] = {0.0, 0.0, 10.0, 1.0}; // omni from this pos.
	
	glDisable(GL_CULL_FACE);
	glEnable(GL_LIGHT0);
	glLightfv(GL_LIGHT0, GL_AMBIENT, ambient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuse);
	glLightfv(GL_LIGHT0, GL_SPECULAR, specular);
	glLightfv(GL_LIGHT0, GL_POSITION, lightPos);
	
	GLfloat one[] = { 1.0f };
	GLfloat no_shininess[] = { 0.0f };
	GLfloat diffuseMat[] = {1,1,1,1};
	glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, no_shininess);
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, diffuseMat);
#endif
	
	glEnable(GL_TEXTURE_2D);
	
	for (Flap *flap in [self flapsForDrawing])
	{
		[flap drawOpenGL];
	}

	GLfloat lineVerts[] = {-1, 0, 1, 0};

	glVertexPointer(2, GL_FLOAT, 0, lineVerts);
	glEnableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

	glLineWidth(4);
	glColor4f(0, 0, 0, 1);
	glDrawArrays(GL_LINES, 0, 2);

}

@end
