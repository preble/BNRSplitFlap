//
//  Flap.m
//  SplitFlap
//
//  Created by Adam Preble on 4/19/12.
//  Copyright (c) 2012 Big Nerd Ranch. All rights reserved.
//

#import "Flap.h"
#import <GLKit/GLKit.h>
#import "BitmapFont.h"

@implementation Flap

@synthesize front = mFront;
@synthesize back = mBack;
@synthesize ticksAtRest = mTicksAtRest;
@synthesize hidden = mHidden;

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ front=%@ back=%@ hidden=%d ticksAtRest=%d", NSStringFromClass([self class]), mFront, mBack, mHidden, mTicksAtRest];
}

- (void)reset
{
	mAngle = 0;
	mInMotion = NO;
	mTicksAtRest = 0;
	mHidden = NO;
}

- (void)tick
{
	if (!mInMotion)
		return;
	
	mAngle += 16.0;
	if (mAngle >= 180)
	{
		mAngle = 180;
		mTicksAtRest++;
		
//		if (mTicksAtRest == 1)
//			NSLog(@"%@ is now at rest", self);
	}
}

- (void)trip
{
	mInMotion = YES;
	mTicksAtRest = 0;
}

- (float)angle
{
	return mAngle;
}

#define GLERR

- (void)drawOpenGL
{
	if (mHidden)
		return;
	
	BitmapFont *font = [BitmapFont standardFont];
	glBindTexture(GL_TEXTURE_2D, [[font texture] name]);
	
	glPushMatrix();
	
	glRotatef(-mAngle, 1, 0, 0);
	
	CGRect textureRect;
	if (mAngle < 90)
	{
		// We are still on the top half
		textureRect = [font normalizedFrameForCharacter:mFront];
		GLfloat halfHeight = textureRect.size.height * 0.5;
		
		textureRect.size.height -= halfHeight;
	}
	else
	{
		// We are on the bottom half
		textureRect = [font normalizedFrameForCharacter:mBack];
		GLfloat halfHeight = textureRect.size.height * 0.5;
		
		textureRect.origin.y += 2.0 * halfHeight;
		textureRect.size.height = -halfHeight;
	}
	
	GLfloat x0 = CGRectGetMinX(textureRect);
	GLfloat y0 = textureRect.origin.y;
	GLfloat x1 = CGRectGetMaxX(textureRect);
	GLfloat y1 = textureRect.origin.y + textureRect.size.height;
	
	const GLfloat letterAspectRatio = (2.0*fabs(textureRect.size.height)) / textureRect.size.width;
	const GLfloat halfHeight = 1.0;
	const GLfloat halfWidth = 1.0;
	const GLfloat letterWidth = 1.5/letterAspectRatio;
	
	const GLfloat squareVertices[] = {
        -halfWidth, -halfHeight * 0,
		halfWidth, -halfHeight * 0
		,
        -halfWidth,  halfHeight,
		halfWidth,  halfHeight,
    };
	
	const GLfloat letterVertices[] = {
        -letterWidth, -halfHeight * 0,
		letterWidth, -halfHeight * 0
		,
        -letterWidth,  halfHeight,
		letterWidth,  halfHeight,
    };

	GLfloat textureCoords[] = {
		x0, y1, //0,1,
		x1, y1, //1,1,
		x0, y0, //0,0,
		x1, y0, //1,0
	};
	
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	GLERR;
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glColor4f(0, 0, 0, 1);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	

	glEnable(GL_TEXTURE_2D);
	glVertexPointer(2, GL_FLOAT, 0, letterVertices);

	glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glColor4f(1, 1, 1, 1);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	GLERR;
	
	glPopMatrix();
}

@end
