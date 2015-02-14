//
//  AudioRecordingViewController.h
//  Bestiary
//
//  Created by Joe on 6/5/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol AudioDelegate <NSObject>

@required

-(void)audioSavedWithRecorder:(AVAudioRecorder *) recorderWithSound withPlayer :(AVAudioPlayer*) recorderWithSound withURL:(NSString*)audioSavedURL;


@end 


@interface AudioRecordingViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong,nonatomic)id<AudioDelegate> delegate;
-(void)initPlayerFromSavedEntry:(NSString*)url withData:(NSData*)data;
@property (nonatomic, assign) BOOL existingFile;



@end
