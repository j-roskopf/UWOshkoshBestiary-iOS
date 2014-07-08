//
//  AudioRecordingViewController.m
//  Bestiary
//
//  Created by Joe on 6/5/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import "AudioRecordingViewController.h"
#import "FirstViewController.h"

@interface AudioRecordingViewController ()
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSString *savedUrl;
    NSData *audioData;
    NSURL *soundFileURL;
    
}
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation AudioRecordingViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    
    // Do any additional setup after loading the view.
    
    // Disable Stop/Play button when application launches
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:NO];
    

    
    // Create a new dated file
    
    if(!_existingFile)
    {
        NSArray *dirPaths;
        NSString *docsDir;
        
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPaths[0];
        
        time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
        NSString *timeStamp=[NSString stringWithFormat:@"%ld",unixTime];
        
        savedUrl = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_recordedSound.caf",timeStamp]];
    }
    else{
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:savedUrl];
        
        NSLog(fileExists ? @"yes" : @"no");
        [_playButton setEnabled:YES];
}

    
    soundFileURL = [NSURL fileURLWithPath:savedUrl];
    

    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    

    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt:2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    if(error){
        NSLog(@"error: %@", [error localizedDescription]);
    }


    

    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)play:(id)sender {
    if(!recorder.recording){
        _recordButton.enabled = NO;
        _stopButton.enabled = YES;
        
        NSError *error1;
        NSError *error2;
        NSData *soundFile = [[NSData alloc] initWithContentsOfURL:recorder.url options:NSDataReadingMappedIfSafe error:&error1];
        
        player = [[AVAudioPlayer alloc] initWithData:soundFile error:&error2];
        
        player.delegate = self;
        
        if(error1){
            NSLog(@"error1: %@", [error1 localizedDescription]);
        } else if (error2) {
            NSLog(@"error2: %@", [error2 localizedDescription]);
        } else {
            [player play];
        }
    }
    
    [_stopButton setEnabled:NO];
    [_recordButton setEnabled:YES];
   
}
- (IBAction)stop:(id)sender {
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [_playButton setEnabled:YES];
    
    [_recordButton setEnabled:YES];
    
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    



    
    
    
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog([error localizedDescription]);
}
- (IBAction)recordAndPause:(id)sender {

    [recorder prepareToRecord];
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    [_stopButton setEnabled:YES];
    [_playButton setEnabled:NO];

    
    if (!recorder.recording) {
        
        // Start recording
        [recorder record];
        [_recordButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
        [recorder pause];
        [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}
- (IBAction)saveFile:(id)sender {

    [recorder stop];
    [_delegate audioSavedWithRecorder:recorder withPlayer:player];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)initPlayerFromSavedEntry:(NSString*)url withData:(NSData*)data
{
    savedUrl = url;
    audioData = data;
}








@end
