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
    

    

    
    if(audioData == nil)
    {
        // Set the audio file
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   @"MyAudioMemo.m4a",
                                   nil];
        
        soundFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        savedUrl = [soundFileURL absoluteString];
        
        

    }
    else{
        
        
        NSLog(@"audio data is not null");
        [_playButton setEnabled:YES];
        soundFileURL = [NSURL URLWithString:savedUrl];



    }

    
    

    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];


    

    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)play:(id)sender {
    if (!recorder.recording){
        if(audioData == nil){
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        }else{
            player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
        }
        [player setDelegate:self];
        [player play];
        
        [_stopButton setEnabled:NO];
        [_recordButton setEnabled:YES];
    }
//    if(!recorder.recording){
//        _recordButton.enabled = NO;
//        _stopButton.enabled = YES;
//        
//        NSError *error1;
//        NSError *error2;
//        NSData *soundFile = [[NSData alloc] initWithContentsOfURL:recorder.url options:NSDataReadingMappedIfSafe error:&error1];
//        audioData = soundFile;
//        
//        if(audioData != nil){
//            player = [[AVAudioPlayer alloc] initWithData:audioData error:&error2];
//        }
//        
//        player.delegate = self;
//        
//        if(error1){
//            NSLog(@"error1: %@", [error1 localizedDescription]);
//        } else if (error2) {
//            NSLog(@"error2: %@", [error2 localizedDescription]);
//        } else {
//            [player play];
//        }
//    }
//    
//    [_stopButton setEnabled:NO];
//    [_recordButton setEnabled:YES];
   
}
- (IBAction)stop:(id)sender {
    
    [recorder stop];
    
    NSData *soundFile = [[NSData alloc] initWithContentsOfURL:recorder.url options:NSDataReadingMappedIfSafe error:nil];
    audioData = soundFile;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [_playButton setEnabled:YES];
    
    [_recordButton setEnabled:NO];
    
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog([error localizedDescription]);
}
- (IBAction)recordAndPause:(id)sender {


    
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [_recordButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
        [recorder pause];
        [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    

    [_stopButton setEnabled:YES];
    [_playButton setEnabled:NO];
    
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}
- (IBAction)saveFile:(id)sender {
    
    

    

    
    if(audioData == nil){
        NSLog(@"YEAH ITS NULL");
    }
    [recorder stop];
    [[player data] writeToURL:[NSURL URLWithString:savedUrl] atomically:YES];
    [_delegate audioSavedWithRecorder:recorder withPlayer:player withURL:savedUrl];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)initPlayerFromSavedEntry:(NSString*)url withData:(NSData*)data
{
    savedUrl = url;
    audioData = data;
}








@end
