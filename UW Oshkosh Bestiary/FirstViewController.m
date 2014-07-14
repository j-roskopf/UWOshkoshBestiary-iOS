//
//  FirstViewController.m
//  Bestiary
//
//  Created by Joe on 5/11/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import "FirstViewController.h"
#import "GroupPhylaViewController.h"
#import "AudioRecordingViewController.h"
#import "CountyViewController.h"
#import "Sighting.h"
#import "AppDelegate.h"
#import "ViewVideoViewController.h"
#import "WeatherViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>



@interface FirstViewController () <CountyDelegate,GroupDelegate,AudioDelegate,WeatherChangedAfterError>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *groupPhylaTextField;
@property (weak, nonatomic) IBOutlet UILabel *countyTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *commonNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *speciesTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *behavioralTextField;
@property (weak, nonatomic) IBOutlet UITextField *observationTextField;
@property (weak, nonatomic) IBOutlet UITextField *ecosystemTextField;
@property (weak, nonatomic) IBOutlet UITextField *additionalTextField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *latitudeTextField;

@property (weak, nonatomic) IBOutlet UITextField *altitudeTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageOutlet;
@property (weak, nonatomic) IBOutlet UILabel *audioStatusTextField;
@property (weak, nonatomic) IBOutlet UISwitch *tosSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *affiliationSegControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *observationTechSegControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *locationSegControl;
@property (weak, nonatomic) IBOutlet UIButton *viewVideoButton;





//TEST


@end

CLLocationManager *locationManager;

@implementation FirstViewController
{
    CGPoint offsetBeforeTransition;
    UIGestureRecognizer *tapper;
    
    //Stores the active text field
    UITextField* activeField;
    
    //Holds if the user has at least ios6
    BOOL atLeastIOS6;
    
    //Holds the recorded audio file
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    

    
    //Used for storing sightings into local DB
    NSManagedObjectContext *context;
    
    //Weater variables
    float rain;
    float temperature;
    float pressure;
    float windSpeed;
    NSString *windDirection;
    NSString *precipitationMeasure;
    
    
    //Used to store audio file URL and data
    NSString *audioUrl;
    NSData *audioData;
    
    //Used to store the time of the selected photo / video
    NSString *photoTime;
    NSString *videoTime;

}
- (IBAction)capturePicture:(id)sender {
    
    

    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Choose picture source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo/Video",@"Choose From Library", nil];
    [actionSheet showInView:self.view];
    

}
- (IBAction)discardSubmission:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Confirm discard"
                          message:@"This cannot be undone"
                          delegate:self  // set nil if you don't want the yes button callback
                          cancelButtonTitle:@"No"
                          otherButtonTitles:@"Yes", nil];
    [alert show];

}


// yes button callback
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:
(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        //Sets video to null
        _videoURL = nil;
        
        //Sets the image back to the gray square
        UIColor *color = [UIColor lightGrayColor];
        UIImage *image = [self imageWithColor:color];
        
        //set the image to be a gray square
        _imageOutlet.image = image;
        
        audioData = nil;
        audioUrl = @"";
        
        _firstNameTextField.text = @"";
        _lastNameTextField.text = @"";
        _emailTextField.text = @"";

        [_affiliationSegControl setSelectedSegmentIndex:0];

        
        _groupPhylaTextField.text = @"Group/Phyla";
        _commonNameTextField.text = @"";
        _speciesTextField.text = @"";
        _amountTextField.text = @"";
        _behavioralTextField.text = @"";
        _countyTextField.text = @"County";
        

        [_observationTechSegControl setSelectedSegmentIndex:0];

        _observationTextField.text = @"";
        _ecosystemTextField.text = @"";
        _additionalTextField.text = @"";
        _longitudeTextField.text = @"";
        _latitudeTextField.text = @"";
        _altitudeTextField.text = @"";
        
        rain = 0;
        temperature = 0;
        windSpeed = 0;
        windDirection = 0;
        pressure = 0;
        precipitationMeasure = @"3h";
        

        [_locationSegControl setSelectedSegmentIndex:0];
        
        _existingSubmission = NO;


    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            
            imagePicker.delegate = self;
            
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypeCamera;
            
            imagePicker.mediaTypes =
            @[(NSString *) kUTTypeImage,
              (NSString *) kUTTypeMovie];
            
            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker
                               animated:YES completion:nil];
            
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Can't access camera" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
            [alert show];
            
        }
        

        
        
    } else if (buttonIndex == 1) {
        
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            
            imagePicker.delegate = self;
            
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
            
            imagePicker.mediaTypes =
            @[(NSString *) kUTTypeImage,
              (NSString *) kUTTypeMovie];
            
            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker
                               animated:YES completion:nil];
            
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Can't access photo library" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
            [alert show];
            
        }
        
        
    }
    
    
    
    
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    if ([mediaType isEqualToString:(NSString *)kUTTypeVideo] ||
        [mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        [_viewVideoButton setEnabled:YES];
        
        self.videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
            NSDate *date = [asset valueForProperty:ALAssetPropertyDate];

            
            NSLocale* currentLocale = [NSLocale currentLocale];
            //If date = nil, that means the user took a new video, so the video time will just be a new time stamp. If it's not null, then the date is of the time the file was created
            if(date == nil)
            {
                NSDate *currentDate = [NSDate date];
                videoTime = [currentDate descriptionWithLocale:currentLocale];
            }
            else
            {
                videoTime = [date descriptionWithLocale:currentLocale];
            }
        } failureBlock:nil];
        
        



    }
    else
    {

        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        _imageOutlet.image = image;
        
        //TODO SET DATE AND TIME PICTURE WAS TAKEN
        if(atLeastIOS6){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            [self dismissModalViewControllerAnimated:YES];
        }
        
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
            NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
            
            NSLocale* currentLocale = [NSLocale currentLocale];
            
            //If date = nil, that means the user took a new photo, so the video time will just be a new time stamp. If it's not null, then the date is of the time the file was created
            if(date == nil)
            {
                NSDate *currentDate = [NSDate date];
                photoTime = [currentDate descriptionWithLocale:currentLocale];
            }
            else
            {
                photoTime = [date descriptionWithLocale:currentLocale];
            }
        
            
        } failureBlock:nil];
        

        

    }
    

    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //Hasnt been an internet connection error yet
    _internetError = NO;
    
    //Registers observer for keyboard being shown/hidden
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    //Handles tap to dismiss keyboard
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    //Checks if user is at least ios6
    atLeastIOS6 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0;
    

    
    
    
    if(!_existingSubmission)
    {
        UIColor *color = [UIColor lightGrayColor];
        UIImage *image = [self imageWithColor:color];
        
        //set the image to be a gray square
        _imageOutlet.image = image;
        
        //If the user has entered a submission before, populate their first/last name and email from user defaults
        NSString *firstName = [[NSUserDefaults standardUserDefaults]
                               stringForKey:@"firstName"];
        NSString *lastName = [[NSUserDefaults standardUserDefaults]
                              stringForKey:@"lastName"];
        NSString *email = [[NSUserDefaults standardUserDefaults]
                           stringForKey:@"email"];
        
        _firstNameTextField.text = firstName;
        _lastNameTextField.text = lastName;
        _emailTextField.text = email;
        
        
        //Starts location object
        if(locationManager == nil)
            locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.distanceFilter = 100;
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
    }
    else{
        UIImage *image = [UIImage imageWithData:[_existingSighting image]];
        if(image != nil)
        {
            _imageOutlet.image = image;
        }
        
        self.title = @"Existing Submission";
        
        audioUrl = _existingSighting.audioUrl;
        
        NSString *temp = [NSString stringWithFormat:@"photo time %@", _existingSighting.photoTime];
        
        NSLog(temp);
        
        NSString *temp1 = [NSString stringWithFormat:@"video time %@", _existingSighting.videoTime];
        
        NSLog(temp1);
        
        
        



        
        if(audioUrl != nil)
        {
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:audioUrl];
            
            NSLog(fileExists ? @"yes" : @"no");
            _audioStatusTextField.text = @"Recorded";
            _audioStatusTextField.textAlignment = NSTextAlignmentCenter;
            audioData = _existingSighting.audioData;

        }

        
        _videoURL = [NSURL URLWithString:_existingSighting.videoUrl];
        
        _firstNameTextField.text = _existingSighting.firstName;
        _lastNameTextField.text = _existingSighting.lastName;
        _emailTextField.text = _existingSighting.email;
        
        if([_existingSighting.affiliation isEqualToString:@"UW Oshkosh"])
        {
            [_affiliationSegControl setSelectedSegmentIndex:0];
        }
        else
        {
            [_affiliationSegControl setSelectedSegmentIndex:1];

        }
        
        _groupPhylaTextField.text = _existingSighting.group;
        _commonNameTextField.text = _existingSighting.commonName;
        _speciesTextField.text = _existingSighting.species;
        _amountTextField.text = _existingSighting.amount;
        _behavioralTextField.text = _existingSighting.behavorialDescription;
        _countyTextField.text = _existingSighting.county;
        
        if([_existingSighting.technique isEqualToString:@"Casual"])
        {
            [_observationTechSegControl setSelectedSegmentIndex:0];
        }
        else if([_existingSighting.technique isEqualToString:@"Stationary"])
        {
            [_observationTechSegControl setSelectedSegmentIndex:1];
        }
        else if([_existingSighting.technique isEqualToString:@"Traveling"])
        {
            [_observationTechSegControl setSelectedSegmentIndex:2];
        }
        else if([_existingSighting.technique isEqualToString:@"Area"])
        {
            [_observationTechSegControl setSelectedSegmentIndex:3];
        }
        _observationTextField.text = _existingSighting.observationalTechniqueOther;
        _ecosystemTextField.text = _existingSighting.ecosystem;
        _additionalTextField.text = _existingSighting.additionalInformation;
        _longitudeTextField.text = _existingSighting.longitude;
        _latitudeTextField.text = _existingSighting.latitude;
        _altitudeTextField.text = _existingSighting.altitude;
        
        rain = [_existingSighting.precipitation floatValue];
        temperature = [_existingSighting.temperature floatValue];
        windSpeed = [_existingSighting.windSpeed floatValue];
        windDirection = _existingSighting.windDirection;
        pressure = [_existingSighting.pressure floatValue];
        precipitationMeasure = _existingSighting.precipitationMeasure;
        
        if([_existingSighting.privacy isEqualToString:@"Public"])
        {
            [_locationSegControl setSelectedSegmentIndex:0];
        }
        else if([_existingSighting.privacy isEqualToString:@"Private"])
        {
            [_locationSegControl setSelectedSegmentIndex:1];
        }
        else if([_existingSighting.privacy isEqualToString:@"Obscured"])
        {
            [_locationSegControl setSelectedSegmentIndex:2];
        }
        
        
        
        
    }

    

    
    //Hides scroll view until user agrees to TOS
    _scrollView.hidden = YES;
    
    

}
- (IBAction)switchPressed:(id)sender {
    if(_tosSwitch.isOn)
    {
        _scrollView.hidden = NO;
    }
    else{
        _scrollView.hidden = YES;

    }

}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    float thisy,maxy=0;
    for (UIView *view in _scrollView.subviews) {
        thisy=view.frame.origin.y+view.frame.size.height;
        maxy=(thisy>maxy) ? thisy : maxy;
    }
    _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,maxy+20);
    
    [_scrollView setContentOffset:offsetBeforeTransition animated: NO];
    

}

-(void)countyChanged:(NSString *)county {
    
    [_countyTextField setText:county];

}

-(void)audioSavedWithRecorder:(AVAudioRecorder *) recorderWithSound withPlayer:(AVAudioPlayer*) playerWithSound{
    _audioStatusTextField.text = @"Recorded";
    _audioStatusTextField.textAlignment = NSTextAlignmentCenter;
    
    recorder = recorderWithSound;
    player = playerWithSound;
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:recorder.url.path];
    
    NSLog(fileExists ? @"yes" : @"no");



}

-(void)groupChanged:(NSString *)group {
    
    [_groupPhylaTextField setText:group];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueCounty"]) {
        
        CountyViewController *countyController = segue.destinationViewController;
        countyController.delegate = self;
        
        offsetBeforeTransition = _scrollView.contentOffset;

        
    }
    else if ([segue.identifier isEqualToString:@"segueGroup"]) {
        
        GroupPhylaViewController *groupController = segue.destinationViewController;
        groupController.delegate = self;
        
        offsetBeforeTransition = _scrollView.contentOffset;

    }
    else if ([segue.identifier isEqualToString:@"segueAudio"]) {
        
        AudioRecordingViewController *audioController = segue.destinationViewController;
        audioController.delegate = self;
        if(_existingSubmission  || recorder)
        {
            if(audioUrl == nil && recorder.url.path != nil)
            {
                audioUrl = recorder.url.path;
            }
            audioController.existingFile = YES;
            [audioController initPlayerFromSavedEntry:audioUrl withData:audioData];


        }
        
        offsetBeforeTransition = _scrollView.contentOffset;

    }
    else if ([segue.identifier isEqualToString:@"segueWeather"]) {
        
        WeatherViewController *weatherController = segue.destinationViewController;
        weatherController.delegate = self;
        if(!_internetError)
        {
            [weatherController weatherSaved:rain withDegrees:temperature withWindSpeed:windSpeed withWindDirection:windDirection withPressure:pressure withPrecipitationMeasure:precipitationMeasure];
        }
        else{
            weatherController.errorCollectingWeather = YES;
        }
        
        offsetBeforeTransition = _scrollView.contentOffset;


    }
    
    else if ([segue.identifier isEqualToString:@"segueVideo"]) {
        
        ViewVideoViewController *videoController = segue.destinationViewController;
        
        [videoController receivedVideoUrl:_videoURL];
        
        offsetBeforeTransition = _scrollView.contentOffset;

        
        
    }
    

}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (IBAction)saveEntry:(id)sender {
    
    NSString *messageString;
    bool errorInSubmission = NO;
    
    if([_firstNameTextField.text isEqual: @""])
    {
        messageString = @"Please enter in your first name";
        errorInSubmission = YES;
    }
    else if([_lastNameTextField.text  isEqual: @""])
    {
        messageString = @"Please enter in your last name";
        errorInSubmission = YES;
    }
    else if([_emailTextField.text  isEqual: @""])
    {
        messageString = @"Please enter in your email";
        errorInSubmission = YES;
    }
    else if([_groupPhylaTextField.text  isEqual: @"Group/Phyla"])
    {
        messageString = @"Please choose a Group/Phyla";
        errorInSubmission = YES;
    }
    
    if(errorInSubmission == YES)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field Detected" message:messageString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
        [alert show];
    }
    else
    {
        
        context = [self managedObjectContext];
        NSError *error;


        
        if(_existingSighting)
        {
            
            [_existingSighting setValue:[_firstNameTextField text] forKey:@"firstName"];
            [_existingSighting setValue:[_lastNameTextField text] forKey:@"lastName"];
            [_existingSighting setValue:[_emailTextField text] forKey:@"email"];
            
            if ([_affiliationSegControl selectedSegmentIndex] == 0) {
                [_existingSighting setValue:@"UW Oshkosh" forKey:@"affiliation"];
            } else if ([_affiliationSegControl selectedSegmentIndex] == 1) {
                [_existingSighting setValue:@"Other" forKey:@"affiliation"];
            }
            
            [_existingSighting setValue:[_groupPhylaTextField text] forKey:@"group"];
            
            [_existingSighting setValue:[_commonNameTextField text] forKey:@"commonName"];
            [_existingSighting setValue:[_speciesTextField text] forKey:@"species"];
            [_existingSighting setValue:[_firstNameTextField text] forKey:@"firstName"];
            [_existingSighting setValue:[_amountTextField text] forKey:@"amount"];
            [_existingSighting setValue:[_behavioralTextField text] forKey:@"behavorialDescription"];
            [_existingSighting setValue:[_speciesTextField text] forKey:@"species"];
            
            
            [_existingSighting setValue:[_countyTextField text] forKey:@"county"];
            
            if ([_observationTechSegControl selectedSegmentIndex] == 0) {
                [_existingSighting setValue:@"Casual" forKey:@"technique"];
            } else if ([_observationTechSegControl selectedSegmentIndex] == 1) {
                [_existingSighting setValue:@"Stationary" forKey:@"technique"];
            }
            else if ([_observationTechSegControl selectedSegmentIndex] == 2) {
                [_existingSighting setValue:@"Traveling" forKey:@"technique"];
            }
            else if ([_observationTechSegControl selectedSegmentIndex] == 3) {
                [_existingSighting setValue:@"Area" forKey:@"technique"];
            }
            
            [_existingSighting setValue:[_observationTextField text] forKey:@"observationalTechniqueOther"];
            [_existingSighting setValue:[_ecosystemTextField text] forKey:@"ecosystem"];
            [_existingSighting setValue:[_additionalTextField text] forKey:@"additionalInformation"];
            [_existingSighting setValue:[_longitudeTextField text] forKey:@"longitude"];
            
            [_existingSighting setValue:[_latitudeTextField text] forKey:@"latitude"];
            
            [_existingSighting setValue:[_altitudeTextField text] forKey:@"altitude"];
            
            
            if ([_locationSegControl selectedSegmentIndex] == 0) {
                [_existingSighting setValue:@"Public" forKey:@"privacy"];
            } else if ([_locationSegControl selectedSegmentIndex] == 1) {
                [_existingSighting setValue:@"Private" forKey:@"privacy"];
            }
            else if ([_locationSegControl selectedSegmentIndex] == 2) {
                [_existingSighting setValue:@"Obscured" forKey:@"privacy"];
            }
            
            //Saving Audio/Picture/Video
            
            NSData *imageData = UIImagePNGRepresentation([_imageOutlet image]);
            [_existingSighting setValue:imageData forKey:@"image"];
            
            if([player data] != nil)
            {
                audioData = [player data];
                [_existingSighting setValue:audioData forKey:@"audioData"];
            }
            
            [_existingSighting setValue:recorder.url.path forKey:@"audioUrl"];
            
            NSString *videoData = _videoURL.absoluteString;
            [_existingSighting setValue:videoData forKey:@"videoUrl"];
            
            

            //Saving time for the photo/video
            [_existingSighting setValue:photoTime forKeyPath:@"photoTime"];
            [_existingSighting setValue:videoTime forKeyPath:@"videoTime"];
            
            
            //Shouldn't be any need to re-save the weather or date

            [[_existingSighting managedObjectContext]save:&error];


            [self.navigationController popViewControllerAnimated:YES];
            

            
        }
        else {
            
            
            

            Sighting *s = [NSEntityDescription insertNewObjectForEntityForName:@"Sighting"inManagedObjectContext:context];
            
            
            
            //Saving form data
            
            [s setValue:[_firstNameTextField text] forKey:@"firstName"];
            [s setValue:[_lastNameTextField text] forKey:@"lastName"];
            [s setValue:[_emailTextField text] forKey:@"email"];
            
            if ([_affiliationSegControl selectedSegmentIndex] == 0) {
                [s setValue:@"UW Oshkosh" forKey:@"affiliation"];
            } else if ([_affiliationSegControl selectedSegmentIndex] == 1) {
                [s setValue:@"Other" forKey:@"affiliation"];
            }
            
            [s setValue:[_groupPhylaTextField text] forKey:@"group"];
            
            [s setValue:[_commonNameTextField text] forKey:@"commonName"];
            [s setValue:[_speciesTextField text] forKey:@"species"];
            [s setValue:[_firstNameTextField text] forKey:@"firstName"];
            [s setValue:[_amountTextField text] forKey:@"amount"];
            [s setValue:[_behavioralTextField text] forKey:@"behavorialDescription"];
            [s setValue:[_speciesTextField text] forKey:@"species"];
            
            
            [s setValue:[_countyTextField text] forKey:@"county"];
            
            if ([_observationTechSegControl selectedSegmentIndex] == 0) {
                [s setValue:@"Casual" forKey:@"technique"];
            } else if ([_observationTechSegControl selectedSegmentIndex] == 1) {
                [s setValue:@"Stationary" forKey:@"technique"];
            }
            else if ([_observationTechSegControl selectedSegmentIndex] == 2) {
                [s setValue:@"Traveling" forKey:@"technique"];
            }
            else if ([_observationTechSegControl selectedSegmentIndex] == 3) {
                [s setValue:@"Area" forKey:@"technique"];
            }
            
            [s setValue:[_observationTextField text] forKey:@"observationalTechniqueOther"];
            [s setValue:[_ecosystemTextField text] forKey:@"ecosystem"];
            [s setValue:[_additionalTextField text] forKey:@"additionalInformation"];
            [s setValue:[_longitudeTextField text] forKey:@"longitude"];
            
            [s setValue:[_latitudeTextField text] forKey:@"latitude"];
            
            [s setValue:[_altitudeTextField text] forKey:@"altitude"];
            
            
            if ([_locationSegControl selectedSegmentIndex] == 0) {
                [s setValue:@"Public" forKey:@"privacy"];
            } else if ([_locationSegControl selectedSegmentIndex] == 1) {
                [s setValue:@"Private" forKey:@"privacy"];
            }
            else if ([_locationSegControl selectedSegmentIndex] == 2) {
                [s setValue:@"Obscured" forKey:@"privacy"];
            }
            
            //Saving Audio/Picture or video
            
            NSData *imageData = UIImagePNGRepresentation([_imageOutlet image]);
            
            [s setValue:imageData forKey:@"image"];
            
            audioData = [player data];

            [s setValue:[[recorder url] path] forKey:@"audioUrl"];
            
            [s setValue: audioData forKey:@"audioData"];
            
            NSString *videoData = _videoURL.absoluteString;
            [s setValue:videoData forKey:@"videoUrl"];

            
            
            //Saving weather
            [s setValue:[NSNumber numberWithFloat:rain] forKey:@"precipitation"];
            [s setValue:[NSNumber numberWithFloat:temperature] forKey:@"temperature"];
            [s setValue:[self windDirectionForDegrees:windSpeed] forKey:@"windDirection"];
            [s setValue:[NSNumber numberWithFloat:pressure] forKey:@"pressure"];
            [s setValue:[NSNumber numberWithFloat:windSpeed] forKey:@"windSpeed"];
            [s setValue:precipitationMeasure forKey:@"precipitationMeasure"];
            
            
            
            //Saving the date
            [s setValue:[NSDate date] forKey:@"date"];
            
            //Saving the photo time
            [s setValue:photoTime forKey:@"photoTime"];
            
            //Saving the video time
            [s setValue:videoTime forKey:@"videoTime"];
            

            
            
            [context save:&error];
            
            

            
        }
        
        // Store the first name/ last name / email
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:[_firstNameTextField text] forKey:@"firstName"];
        [defaults setObject:[_lastNameTextField text] forKey:@"lastName"];
        [defaults setObject:[_emailTextField text] forKey:@"email"];

        [defaults synchronize];
        
        
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Submission saved to local storage" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
        [alert show];
        
        _existingSubmission = true;
        [self.tabBarController setSelectedIndex:1];
        

    }
    
    
    
    
    
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *location = [locations lastObject];

        CLLocationCoordinate2D coordinate= location.coordinate;
        _longitudeTextField.text = [NSString stringWithFormat:@"%g\u00B0", coordinate.longitude];
        _latitudeTextField.text = [NSString stringWithFormat:@"%g\u00B0", coordinate.latitude];
        _altitudeTextField.text = [NSString stringWithFormat:@"%gm", location.altitude];
    
    //Stops finding location to save battery
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    
    //Creates the url to call
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f",coordinate.latitude, coordinate.longitude];
    
    //Makes a call to Open Weather to gather the weather after receiving location
    AFHTTPRequestOperationManager *HTTPManager = [AFHTTPRequestOperationManager manager];
    [HTTPManager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *tempTemperature= responseObject[@"main"][@"temp"];
             temperature = [tempTemperature floatValue]-273.15;
             
             NSString *tempWindSpeed = responseObject[@"wind"][@"speed"];
             windSpeed = [tempWindSpeed floatValue];
             
             NSString *tempWindDegrees = responseObject[@"wind"][@"deg"];
             windDirection = [self windDirectionForDegrees:[tempWindDegrees floatValue]];
             
             NSString *tempPressure = responseObject[@"main"][@"pressure"];
             pressure = [tempPressure floatValue];
             
             //Open weather can return three different formats for rain
             NSString *rain1 = responseObject[@"rain"][@"1h"];
             NSString *rain2 = responseObject[@"rain"][@"2h"];
             NSString *rain3 = responseObject[@"rain"][@"3h"];
             
             
             if(rain1 == nil && rain2 == nil)
             {
                 rain = [rain3 floatValue];
                 precipitationMeasure = @"3h";
             }
             else if (rain2 == nil && rain3 == nil)
             {
                 rain = [rain1 floatValue];
                 precipitationMeasure = @"1h";


             }
             else if (rain3 == nil && rain1 == nil)
             {
                 rain = [rain2 floatValue];
                 precipitationMeasure = @"2h";

             }
             
             //Making sure rainToUse isn't nil
             if(!rain)
             {
                 rain = 0.0;
             }
             


         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Error"
                                                               message:@"There has been an error. No weather data will be collected"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
             
             [message show];
             
             _internetError = YES;
         }];
    
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error Getting Location"
                                                      message:errorType
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [message show];
}

-(NSString*)windDirectionForDegrees:(float) degrees {
    static NSString *const Directions[] = {
        @"N", @"NNE",  @"NE", @"ENE", @"E", @"ESE", @"SE", @"SSE",
        @"S", @"SSW", @"SW", @"WSW", @"W", @"WNW", @"NW", @"NNW"
    };
    static const int DirectionsCount = sizeof Directions / sizeof *Directions;
    
    int wind = remainder(round((degrees / 360) * DirectionsCount), DirectionsCount);
    if (wind < 0) wind += DirectionsCount;
    return Directions[wind];
}
-(void)weatherSavedAfterError:(float) r withDegrees :(float) degrees withWindSpeed:(float)windSp withWindDirection:(NSString*) windDir withPressure:(float) press withPrecipitationMeasure:(NSString*) precipMeasure;
{
    _internetError = NO;
    rain = r;
    temperature = degrees;
    windSpeed = windSp;
    windDirection = windDir;
    pressure = press;
    precipitationMeasure = precipMeasure;
    


    
}
- (IBAction)collectLocationManually:(id)sender {
    
    //Starts location object
    if(locationManager == nil)
        locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.distanceFilter = 100;
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

@end