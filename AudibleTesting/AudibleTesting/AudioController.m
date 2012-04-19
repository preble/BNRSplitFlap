//
//  AudioController.m
//  AudibleTesting
//
//  Created by Andrew on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioController.h"

@implementation AudioController

- (id)init{
    self = [super init];
    if (self) {
        peak = -160.0f;
        difference = 0.0f;
        [self setupMic];
        [self listen];
    }
    return self;
}



#pragma mark - Mic control

- (void)setupMic{
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    // possibly do some tweaking with the sample rate and channels
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if(recorder)
        NSLog(@"Recorder setup success!");
    else
        NSLog(@"Recorder setup failure: %@",[error description]);
}

- (void)listen{
    if(!recorder)
        [self setupMic];
    if(recorder){
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
    }
}

- (void)stop{
    if(recorder)
        [recorder stop];    
}

- (float)peak{
    return peak;
}

- (void)updateLevels{
    [recorder updateMeters];
    float currentAverage = [recorder averagePowerForChannel:0];
    float currentPeak = [recorder peakPowerForChannel:0];
    if(peak < currentPeak)
        peak = currentPeak;
    float currentDifference = currentPeak - currentAverage;
    if (difference < currentDifference)
        difference = currentDifference;
    NSLog(@"Average input: %f Peak input: %f", currentAverage, currentPeak);
}

- (float)currentPeak{
    [self updateLevels];
    return [recorder peakPowerForChannel:0];
}

- (void)resetPeak{
    peak = -160.0f;
}

- (float)difference{
    return difference;
}

- (float)currentDifference{
    [self updateLevels];
    return [recorder peakPowerForChannel:0] -  [recorder averagePowerForChannel:0];
}

- (void)resetDifference{
    difference = 0.0f;
}

#pragma mark - Sound control


- (void)setSound:(NSString *)soundFile{
    NSLog(@"setting sound file: %@",soundFile);
    audioFile = [[NSString alloc] initWithString:soundFile];
}

- (void)playSound{
//    [recorder stop];
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioFile]){
        NSLog(@"file exists, playing sound");
        NSURL *pathURL = [NSURL fileURLWithPath : audioFile];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioClip);
        AudioServicesPlaySystemSound(audioClip);
    }else
        NSLog(@"error, file not found: %@", audioFile);
}

#pragma mark - Audio cleanup

- (void)dealloc{
    AudioServicesDisposeSystemSoundID(audioClip);
}

@end
