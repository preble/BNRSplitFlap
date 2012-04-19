//
//  BitmapFont.m
//  SplitFlap
//
//  Created by Adam Preble on 4/19/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "BitmapFont.h"

@implementation BitmapFont

@synthesize texture = mTexture;

+ (BitmapFont *)standardFont
{
	static BitmapFont *normal = nil;
	if (!normal)
	{
		normal = [[BitmapFont alloc] initWithName:@"BitmapFont"];
	}
	return normal;
}

- (id)initWithName:(NSString *)fontName
{
	if ((self = [super init]))
	{
		mFontName = fontName;
		NSMutableDictionary *frames = [NSMutableDictionary dictionary];
		
		NSString *errorString;
		NSData *plistData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:fontName withExtension:@"plist"]];
		NSDictionary *framesInput = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:0 format:NULL errorDescription:&errorString];
		if (!framesInput)
		{
			NSLog(@"Error loading plist: %@", errorString);
			return nil;
		}
		for (NSString *key in framesInput)
		{
			CGRect r = CGRectFromString([framesInput objectForKey:key]);
			[frames setObject:[NSValue valueWithCGRect:r] forKey:key];
		}
		mFrames = frames;
		
	}
	return self;
}

- (GLKTextureInfo *)texture
{
	if (!mTexture)
	{
		NSError *err;
		mTexture = [GLKTextureLoader textureWithContentsOfURL:[[NSBundle mainBundle] URLForResource:mFontName withExtension:@"png"]
													  options:nil
														error:&err];
		if (!mTexture)
		{
			NSLog(@"Error loading font: %@", err);
			return nil;
		}
	}
	return mTexture;
}

- (CGRect)frameForCharacter:(NSString *)str
{
	CGRect r = CGRectZero;
	NSValue *v = [mFrames objectForKey:str];
	if (v)
		r = [v CGRectValue];
	return r;
}

- (CGRect)normalizedFrameForCharacter:(NSString *)str
{
	CGRect r = [self frameForCharacter:str];
	CGFloat w = [[self texture] width];
	CGFloat h = [[self texture] height];
	r.origin.x /= w;
	r.origin.y /= h;
	r.size.width /= w;
	r.size.height /= h;
	r.origin.y = 1.0 - r.origin.y - r.size.height;
	return r;
}

- (NSArray *)characters
{
	return [mFrames allKeys];
}

@end
