//
//  AudioController.h
//  AudibleTesting
//
//  Created by Andrew on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface AudioController : NSObject {
    AVAudioRecorder *recorder;
    float peak;
    float difference;
    BOOL listenMode;
    SystemSoundID audioClip;
    NSString *audioFile;
}


- (void)setupMic;
- (void)listen;
- (void)stop;
- (void)updateLevels;
- (float)peak;
- (float)currentPeak;
- (void)resetPeak;
- (float)difference;
- (float)currentDifference;
- (void)resetDifference;


- (void)setSound:(NSString *)soundFile;
- (void)playSound;

@end
