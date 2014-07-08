//
//  ViewVideoViewController.h
//  UW Oshkosh Bestiary
//
//  Created by Joe on 6/18/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewVideoViewController : UIViewController

//Used if the user records a video
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) MPMoviePlayerController *videoController;

-(void)receivedVideoUrl:(NSURL*)url;

@end
