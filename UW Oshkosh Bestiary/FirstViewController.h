//
//  FirstViewController.h
//  Bestiary
//
//  Created by Joe on 5/11/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <ActionSheetPicker.h>
#import <AFNetworking/AFNetworking.h>
#import <AFHTTPRequestOperationManager.h>
#import "Sighting.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>



@interface FirstViewController : UIViewController <UIImagePickerControllerDelegate,CLLocationManagerDelegate, UITabBarControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) BOOL existingSubmission;

//Used to tell if there has been an internet connection error
@property (nonatomic, assign) BOOL internetError;
@property (nonatomic, retain) Sighting *existingSighting;
@property (nonatomic, assign) int selectedRow;

//Used if the user records a video
@property (strong, nonatomic) NSURL *videoURL;


    


@end








