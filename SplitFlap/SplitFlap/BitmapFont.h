//
//  BitmapFont.h
//  SplitFlap
//
//  Created by Adam Preble on 4/19/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface BitmapFont : NSObject {
	NSString *mFontName;
	GLKTextureInfo *mTexture;
	NSDictionary *mFrames;
}

@property (nonatomic, readonly) GLKTextureInfo *texture;
@property (nonatomic, readonly) NSArray *characters;

+ (BitmapFont *)standardFont;

- (id)initWithName:(NSString *)fontName;

- (CGRect)frameForCharacter:(NSString *)str;
- (CGRect)normalizedFrameForCharacter:(NSString *)str;

@end
