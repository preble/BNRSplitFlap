//
//  Digit.h
//  SplitFlap
//
//  Created by Adam Preble on 4/19/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class GLKTextureInfo;

@interface Digit : NSObject {
	NSArray *mCharacters;
	NSUInteger mTopCharacterIndex; // index of the character/flap that is at the top, ready to be tripped
	NSUInteger mTicksUntilNextTrip;
	NSString *mDesiredCharacter;
	GLKTextureInfo *mFlapTexture;
	SystemSoundID mTripSound;
}

@property (nonatomic, strong) NSArray *flaps;

- (void)setCharacter:(NSString *)str animated:(BOOL)animate;

- (void)tick;

- (void)random;

- (void)drawOpenGL;

@end
