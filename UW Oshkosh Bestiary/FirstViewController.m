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
#import "AssetsLibrary/AssetsLibrary.h"
#import "Sighting.h"
#import "AppDelegate.h"
#import "ViewVideoViewController.h"
#import "WeatherViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>



@interface FirstViewController () <CountyDelegate,GroupDelegate,AudioDelegate,WeatherChangedAfterError>
@property (weak, nonatomic) IBOutlet UILabel *groupPhylaTextField;
@property (weak, nonatomic) IBOutlet UILabel *countyTextField;
//@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
//@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *tosText;

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
    
    NSString* URL_FOR_SUBMISSION;
    
    CGRect imageRect;
    
    NSURL* photoURL;
    NSData* photoData;
    
    //Stores the active text field
    UITextField* activeField;
    
    //Holds if the user has at least ios6
    BOOL atLeastIOS6;
    BOOL justClickedOnButton;
    BOOL comingFromChooseFromLibrary;
    
    //Holds the recorded audio file
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    UIActivityIndicatorView *indicator;
    

    
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
    int yValue;
    int amountToAdd;
    id senderToUse;

}
- (IBAction)capturePicture:(id)sender {
    
    

    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Choose picture source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose From Library", nil];
    
    //UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Choose picture source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", nil];
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


-(void)clearFields{
    //Sets video to null
    _videoURL = nil;
    
    //Sets the image back to the gray square
    UIColor *color = [UIColor lightGrayColor];
    UIImage *image = [self imageWithColor:color];
    
    //set the image to be a gray square
    _imageOutlet.image = image;
    
    audioData = nil;
    audioUrl = @"";
    
    //_firstNameTextField.text = @"";
    //_lastNameTextField.text = @"";
    _emailTextField.text = @"";
    
    [_affiliationSegControl setSelectedSegmentIndex:0];
    
    
    _groupPhylaTextField.text = @"* Group/Phyla";
    _commonNameTextField.text = @"";
    _speciesTextField.text = @"";
    _amountTextField.text = @"";
    _behavioralTextField.text = @"";
    _countyTextField.text = @"* County";
    
    
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

// yes button callback for clearing submission
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:
(NSInteger)buttonIndex {
    if(alertView.tag == 100){
        //100 is the tag after the alerview alerting them to a nil phototime
        
        ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"When did the sighting occur" datePickerMode:UIDatePickerModeDateAndTime selectedDate:[NSDate date] target:self action:@selector(dateWasSelected:element:) origin:senderToUse];
        actionSheetPicker.hideCancel = YES;
        [actionSheetPicker showActionSheetPicker];
        
    }else{
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
            
            //_firstNameTextField.text = @"";
            //_lastNameTextField.text = @"";
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

}

//Method for handling 'add photo button'
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
            @[(NSString *) kUTTypeImage];
            
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
            comingFromChooseFromLibrary = true;
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
        
            imagePicker.delegate = self;
        
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
        
            imagePicker.mediaTypes =
            @[(NSString *) kUTTypeImage];
        
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
    
    NSLog(@"DID FINISH PICKING");
    
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
        CGRect frameRect = _imageOutlet.frame;
        frameRect.size.width = 50;
        _imageOutlet.frame = frameRect;

        
        //TODO SET DATE AND TIME PICTURE WAS TAKEN
        if(atLeastIOS6){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            [self dismissModalViewControllerAnimated:YES];
        }
        
        photoURL = info[UIImagePickerControllerReferenceURL];
        NSLog(@"Here123");
        NSLog([photoURL absoluteString]);
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetsLibrary assetForURL:photoURL resultBlock:^(ALAsset *asset) {
            
            
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            
            if(photoData != nil){
                NSLog(@"PHOTO DATA IS NOT NULL");
        
                
            }
            
            NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
            NSLocale* currentLocale = [NSLocale currentLocale];
            
            if(!comingFromChooseFromLibrary){
                [assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
                    if (error) {
                        NSLog(@"error");
                    } else {
                        photoURL = assetURL;
                        NSLog(@"url %@", assetURL.absoluteString);
                    }
                }];
                
                
                //If date = nil, that means the user took a new photo, so the video time will just be a new time stamp. If it's not null, then the date is of the time the file was created
                
                NSDate *currentDate = [NSDate date];
                photoTime = [currentDate descriptionWithLocale:currentLocale];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYY-MM-dd-hh-mm-a"];
                photoTime = [dateFormatter stringFromDate:currentDate];
                
                
                NSString *stringFromDate = [dateFormatter stringFromDate:[NSDate date]];
                NSLog(@"today : %@", stringFromDate);
            }else{
                comingFromChooseFromLibrary = false;
                NSLog(@"Here in else");
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYY-MM-dd-hh-mm-a"];
                NSLog(@"Todays date is %@",[dateFormatter stringFromDate:date]);
                photoTime = [dateFormatter stringFromDate:date];
            }

            


        
            
        } failureBlock:nil];
        

        

        

    }
    

    
    
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
 
    NSURL *url = [NSURL URLWithString:@"http://104.131.21.214/awb_tos.php"];
    [[UIApplication sharedApplication] openURL:url];
    NSLog(@"In should interact with url");
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    comingFromChooseFromLibrary = false;

    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    //NSString* text = @"I have read and agree to the \nTerms of Service \nand verify that I am at least 13 years of age";
    NSString* text = @"I have read and agree to the Terms of Service and I verify that I am at least 13 years of age. NOTE: Please have a parent or guardian contact awisconsinbestiary@gmail.com to set up parental permission if you are under 13 years of age. If you do not check this box you are declining to submit to A Wisconsin Bestiary, Inc.";
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSLinkAttributeName value: @"http://awisconsinbestiary.org/terms-of-use" range: NSMakeRange(29, 17)];
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    [string addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:16.0]
                  range:NSMakeRange(0, string.length)];



    _tosText.attributedText = string;
    
    //Setup progress
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [indicator setHidden:NO];
    

    //Hasnt been an internet connection error yet
    _internetError = NO;
    
    imageRect = _imageOutlet.frame;
    
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
        
        //_firstNameTextField.text = firstName;
        //_lastNameTextField.text = lastName;
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
        
        audioData = _existingSighting.audioData;
                
        if(audioData != nil)
        {
            
            _audioStatusTextField.text = @"Recorded";
            _audioStatusTextField.textAlignment = NSTextAlignmentCenter;
            audioData = _existingSighting.audioData;

        }

        
        _videoURL = [NSURL URLWithString:_existingSighting.videoUrl];
        photoURL = [NSURL URLWithString:_existingSighting.photoUrl];
        
       // _firstNameTextField.text = _existingSighting.firstName;
        //_lastNameTextField.text = _existingSighting.lastName;
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
        
        photoTime = _existingSighting.photoTime;
        NSLog([NSString stringWithFormat:@"SETTING PHOTO TIME TO %@",photoTime]);
        
        
        
        
    }

    

    
    //Hides scroll view until user agrees to TOS
    _scrollView.hidden = YES;
    
    

}
- (IBAction)switchPressed:(id)sender {
    if(_tosSwitch.isOn)
    {
        _scrollView.hidden = NO;
        _tosText.hidden = YES;
        //get frame
        CGRect newFrame = _tosSwitch.frame;
        //set y value to be old y + height
        yValue = newFrame.origin.y;
        
        CGRect tosHeight = _tosText.frame;
        
        newFrame.origin.y = newFrame.origin.y - tosHeight.size.height;
        NSLog([NSString stringWithFormat:@"MINUSING BY %f",0+tosHeight.size.height]);
        _tosSwitch.frame = newFrame;
        CGRect scrollFrame = _scrollView.frame;
        scrollFrame.origin.y = scrollFrame.origin.y - tosHeight.size.height;
        scrollFrame.size.height = scrollFrame.size.height + tosHeight.size.height;
        _scrollView.frame = scrollFrame;
        amountToAdd = tosHeight.size.height;
        
    }
    else{
        _scrollView.hidden = YES;
        _tosText.hidden = NO;
        CGRect newFrame = _tosSwitch.frame;
        NSLog([NSString stringWithFormat:@"SETTING BACK TO TO %i",yValue]);
        newFrame.origin.y = yValue;
        _tosSwitch.frame = newFrame;
        
        CGRect scrollFrame = _scrollView.frame;
        scrollFrame.origin.y = scrollFrame.origin.y + amountToAdd;
        scrollFrame.size.height = scrollFrame.size.height - amountToAdd;
        _scrollView.frame = scrollFrame;

        

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
    NSLog(@"VIEW DID LAYOUT SUBVIEW");
    float thisy,maxy=0;
    for (UIView *view in _scrollView.subviews) {
        thisy=view.frame.origin.y+view.frame.size.height;
        maxy=(thisy>maxy) ? thisy : maxy;
    }
    _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,maxy+20);
    
    [_scrollView setContentOffset:offsetBeforeTransition animated: NO];
    
    if(_tosSwitch.isOn)
    {
        CGRect scrollFrame = _scrollView.frame;
        scrollFrame.origin.y = scrollFrame.origin.y - amountToAdd;
        scrollFrame.size.height = scrollFrame.size.height + amountToAdd;
        _scrollView.frame = scrollFrame;
        
        
        CGRect tosSwitch = _tosSwitch.frame;
        tosSwitch.origin.y = tosSwitch.origin.y - amountToAdd;
        _tosSwitch.frame = tosSwitch;
    }
    

}

-(void)countyChanged:(NSString *)county {
    
    [_countyTextField setText:county];

}

-(void)audioSavedWithRecorder:(AVAudioRecorder *) recorderWithSound withPlayer:(AVAudioPlayer*) playerWithSound withURL:(NSString*)audioSavedURL{
    _audioStatusTextField.text = @"Recorded";
    _audioStatusTextField.textAlignment = NSTextAlignmentCenter;
    
    audioUrl = audioSavedURL;
    recorder = recorderWithSound;
    player = playerWithSound;

    NSData *soundFile = [[NSData alloc] initWithContentsOfURL:recorder.url options:NSDataReadingMappedIfSafe error:nil];
    audioData = soundFile;
    
    if(audioData == nil){
        NSLog(@"YEAH ITS NILL IN AUDIO SAVED WITH RECORDER");
    }
    
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
        NSLog(@"Here");
        audioController.delegate = self;
        if(audioData != nil && audioUrl != nil){
            NSLog(@"Here1");
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
    

        
        context = [self managedObjectContext];
        NSError *error;


        
        if(_existingSighting)
        {
            
            //[_existingSighting setValue:[_firstNameTextField text] forKey:@"firstName"];
            //[_existingSighting setValue:[_lastNameTextField text] forKey:@"lastName"];
            [_existingSighting setValue:[_emailTextField text] forKey:@"email"];
            
            if ([_affiliationSegControl selectedSegmentIndex] == 0) {
                [_existingSighting setValue:@"Other" forKey:@"affiliation"];
            } else if ([_affiliationSegControl selectedSegmentIndex] == 1) {
                [_existingSighting setValue:@"Other" forKey:@"affiliation"];
            }
            
            [_existingSighting setValue:[_groupPhylaTextField text] forKey:@"group"];
            
            [_existingSighting setValue:[_commonNameTextField text] forKey:@"commonName"];
            [_existingSighting setValue:[_speciesTextField text] forKey:@"species"];
            //[_existingSighting setValue:[_firstNameTextField text] forKey:@"firstName"];
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
            
            if(audioData != nil)
            {
                NSLog(@"AUDIO DATA IS NOT NUYLL AT THIS POINT");
                [_existingSighting setValue:audioData forKey:@"audioData"];
            }
            
            [_existingSighting setValue:audioUrl forKey:@"audioUrl"];
            if(photoURL != nil){
                NSString *temp = [photoURL absoluteString];
                [_existingSighting setValue:temp forKey:@"photoUrl"];

            }
            
            NSString *videoData = _videoURL.absoluteString;
            [_existingSighting setValue:videoData forKey:@"videoUrl"];
            
            

            //Saving time for the photo/video
            [_existingSighting setValue:photoTime forKeyPath:@"photoTime"];
            [_existingSighting setValue:videoTime forKeyPath:@"videoTime"];
            
            
            //Weather
//            [_existingSighting setValue:[NSNumber numberWithFloat:rain] forKeyPath:@"precipitation"];
//            [_existingSighting setValue:[NSNumber numberWithFloat:temperature] forKeyPath:@"temperature"];
//            [_existingSighting setValue:[self windDirectionForDegrees:windSpeed] forKeyPath:@"windDirection"];
//            [_existingSighting setValue:[NSNumber numberWithFloat:pressure] forKeyPath:@"pressure"];
//            [_existingSighting setValue:[NSNumber numberWithFloat:windSpeed] forKeyPath:@"windSpeed"];
//            [_existingSighting setValue:precipitationMeasure forKeyPath:@"precipitationMeasure"];

            
            
            //Shouldn't be any need to re-save the weather or date

            [[_existingSighting managedObjectContext]save:&error];
            

            [self.navigationController popViewControllerAnimated:YES];
            

            
        }
        else {
            
            
            

            Sighting *s = [NSEntityDescription insertNewObjectForEntityForName:@"Sighting"inManagedObjectContext:context];
            
            
            
            //Saving form data
            
            //[s setValue:[_firstNameTextField text] forKey:@"firstName"];
            //[s setValue:[_lastNameTextField text] forKey:@"lastName"];
            [s setValue:[_emailTextField text] forKey:@"email"];
            
            if(photoURL != nil){
                [s setValue:[photoURL absoluteString] forKey:@"photoUrl"];

            }

            
            if ([_affiliationSegControl selectedSegmentIndex] == 0) {
                [s setValue:@"Other" forKey:@"affiliation"];
            } else if ([_affiliationSegControl selectedSegmentIndex] == 1) {
                [s setValue:@"Other" forKey:@"affiliation"];
            }
            
            [s setValue:[_groupPhylaTextField text] forKey:@"group"];
            
            [s setValue:[_commonNameTextField text] forKey:@"commonName"];
            [s setValue:[_speciesTextField text] forKey:@"species"];
            //[s setValue:[_firstNameTextField text] forKey:@"firstName"];
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
            
            [s setValue:audioUrl forKey:@"audioUrl"];
            
            if(audioData != nil){
                NSLog(@"AUDIO DATA IS NOT NUYLL AT THIS POINT");

                [s setValue: audioData forKey:@"audioData"];

            }
            
            NSString *videoData = _videoURL.absoluteString;
            [s setValue:videoData forKey:@"videoUrl"];

            
            
            //Saving weather
            [s setValue:[NSNumber numberWithFloat:rain] forKey:@"precipitation"];
            [s setValue:[NSNumber numberWithFloat:temperature] forKey:@"temperature"];
            [s setValue: windDirection forKey:@"windDirection"];
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
        
        //[defaults setObject:[_firstNameTextField text] forKey:@"firstName"];
        //[defaults setObject:[_lastNameTextField text] forKey:@"lastName"];
        [defaults setObject:[_emailTextField text] forKey:@"email"];

        [defaults synchronize];
    
    
        
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Submission saved to local storage" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
        [alert show];
        
        _existingSubmission = true;
        [self.tabBarController setSelectedIndex:1];
        

    
    
    
    
    
    
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
             NSLog(@"HEEEERE");
             //Open weather can return three different formats for rain
             NSString *rain1 = responseObject[@"rain"][@"1h"];
             //NSLog(rain1);
             NSString *rain2 = responseObject[@"rain"][@"2h"];
             //NSLog(rain2);

             NSString *rain3 = responseObject[@"rain"][@"3h"];
             
             //NSLog(rain3);

             
             
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
             
             //[message show];
             
             _internetError = YES;
         }];
    
}

- (void)locationManager: (CLLocationManager *)manager
       didFailWithError: (NSError *)error
{
    [manager stopUpdatingHeading];
    [manager stopUpdatingHeading];

    //Stops finding location to save battery
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    NSLog(@"error%@",error);
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"Please check your network connection or that you are not in airplane mode" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"User has denied to use current Location " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            if(justClickedOnButton == YES){
                justClickedOnButton = NO;
                [alert show];
            }
        }
            break;
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"Unknown network error" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
    }

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
    
    justClickedOnButton = YES;
    //Starts location object
    if(locationManager == nil)
        locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.distanceFilter = 100;
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}
- (IBAction)submit:(id)sender {
    
    NSString *messageString;
    bool errorInSubmission = NO;
    

    
    
    if([_emailTextField.text  isEqual: @""])
    {
        messageString = @"Please enter in your email";
        errorInSubmission = YES;
    }
    else if([_groupPhylaTextField.text  isEqual: @"* Group/Phyla"])
    {
        messageString = @"Please choose a Group/Phyla";
        errorInSubmission = YES;
    }
    else if([_countyTextField.text  isEqual: @"* County"])
    {
        messageString = @"Please choose a county";
        errorInSubmission = YES;
    }
    
    if(errorInSubmission == YES)
    {
        NSLog(@"MISSING");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Field Detected" message:messageString delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
        [alert show];
    }
    else
    {
        
        // Store the first name/ last name / email
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //[defaults setObject:[_firstNameTextField text] forKey:@"firstName"];
        //[defaults setObject:[_lastNameTextField text] forKey:@"lastName"];
        [defaults setObject:[_emailTextField text] forKey:@"email"];
        
        [defaults synchronize];
        
        //Time
        if(photoTime == nil){
            
            senderToUse = sender;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error collectiong time" message:@"Please estimate a date when the photograph/sighting occurred" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
            
            alert.tag = 100;
            [alert show];
            
            

            
            
        }else{
            [indicator startAnimating];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;

            [self submitWithCorrectDate];
        }
        
    }
    
    
}



- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    [indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;

    
    URL_FOR_SUBMISSION = @"http://awisconsinbestiary.org/submissions/";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    
    [manager POST:URL_FOR_SUBMISSION parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
        
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"first-name"];
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding] name:@"last-name"];
        [formData appendPartWithFormData:[[_emailTextField text] dataUsingEncoding:NSUTF8StringEncoding]
         
                                    name:@"replyto"];
        [formData appendPartWithFormData:[@"Bestiary Submission" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"topic"];
        
        
        if ([_affiliationSegControl selectedSegmentIndex] == 0) {
            [formData appendPartWithFormData:[@"other" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"school-affiliation"];
            
        } else if ([_affiliationSegControl selectedSegmentIndex] == 1) {
            [formData appendPartWithFormData:[@"other" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"school-affiliation"];
        }
        
        [formData appendPartWithFormData:[[_groupPhylaTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"animal"];
        
        [formData appendPartWithFormData:[[_commonNameTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"common-name"];
        
        [formData appendPartWithFormData:[[_speciesTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"species"];
        [formData appendPartWithFormData:[[_amountTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"how-many-of-this-animal-did-you-see"];
        [formData appendPartWithFormData:[[_behavioralTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"behavioral-description"];
        [formData appendPartWithFormData:[[_countyTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"county"];
        [formData appendPartWithFormData:[[_longitudeTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"logitude"];
        [formData appendPartWithFormData:[[_altitudeTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"altitude"];
        [formData appendPartWithFormData:[[_latitudeTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"latitude"];
        
        if ([_observationTechSegControl selectedSegmentIndex] == 0) {
            [formData appendPartWithFormData:[@"Casual" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"observation-technique-1"];
        } else if ([_observationTechSegControl selectedSegmentIndex] == 1) {
            [formData appendPartWithFormData:[@"Stationary" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"observation-technique-1"];
        }
        else if ([_observationTechSegControl selectedSegmentIndex] == 2) {
            [formData appendPartWithFormData:[@"Traveling" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"observation-technique-1"];
            
        }
        else if ([_observationTechSegControl selectedSegmentIndex] == 3) {
            [formData appendPartWithFormData:[@"Area" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"observation-technique-1"];
        }
        
        [formData appendPartWithFormData:[[_observationTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"observation-technique"];
        
        
        
        
        if(isnan(temperature)){
            [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"degrees-celcius"];
        }else{
            [formData appendPartWithFormData:[[[NSNumber numberWithFloat:temperature] stringValue] dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"degrees-celcius"];
        }
        
        if(isnan(windSpeed)){
            [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"wind-speed-mph"];
        }else{
            [formData appendPartWithFormData:[[[NSNumber numberWithFloat:windSpeed] stringValue] dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"wind-speed-mph"];
        }
        
        if(windDirection == nil){
            [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"wind-direction"];
        }else{
            [formData appendPartWithFormData:[windDirection dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"wind-direction"];
        }
        
        if(isnan(pressure)){
            [formData appendPartWithFormData:[ @"" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"pressure-mbar"];
        }else{
            [formData appendPartWithFormData:[[[NSNumber numberWithFloat:pressure] stringValue] dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"pressure-mbar"];
        }
        
        
        if(precipitationMeasure == nil){
            
            [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"precipitation-inches"];
        }else{
            
            [formData appendPartWithFormData:[[[NSNumber numberWithFloat:rain] stringValue] dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"precipitation-inches"];
        }
        
        
        
        
        
        
        //START HERE
        
        if(photoURL != nil){
            
            NSLog(@"PHOTO URL IS NOT NULL");
            NSLog([photoURL absoluteString]);
            NSLog(photoURL.path);
            

            
            if(_imageOutlet != nil){
                NSLog(@"IMAGE OUTLET IS NOT NULL");
                NSData *imageData = UIImagePNGRepresentation([_imageOutlet image]);
                
                if(imageData != nil){
                    NSLog(@"IMAGE DATA IS NOT NULL");
                    [formData appendPartWithFileData:imageData name:@"image-to-append_file" fileName:@"picture.png" mimeType:@"application/octet-stream"];
                }

            }
            


            
            NSError* error;
            
            
            if(error != nil){
                //ALERT ERROR HERE
                NSLog(@"BUT THERE WAS AN ERROR %@",error);
            }
            
            
        }
        
        if(audioData != nil){
            
            
            NSLog(@"AUDIO URL IS NOT NULL");
            
            
            [formData appendPartWithFileData:audioData name:@"audio_file" fileName:@"audio_file.m4a" mimeType:@"application/octet-stream"];
            
            
            
            
        }
        
        [formData appendPartWithFormData:[[_additionalTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"specific-text-you-would-like-used-to-acknowledge-photograph-interesting-anecdote-submission"];
        
        
        [formData appendPartWithFormData:[@"Submit" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"form_submit"];
        
        [formData appendPartWithFormData:[@"6b9ec1bdad9b1656f6ebf3720017d3c9118ed11f" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"_authenticator"];
        
        [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"form.submitted"];
        
        [formData appendPartWithFormData:[@"I agree" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"agreement:list"];
        
        [formData appendPartWithFormData:[@"default" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"fieldset"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd-hh-mm-a"];
        //Optionally for time zone converstions
        NSString *stringFromDate = [formatter stringFromDate:selectedDate];
        
        NSArray* dateExploded = [stringFromDate componentsSeparatedByString: @"-"];
        
        
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken"];
        
        

        
        NSLog([dateExploded objectAtIndex: 0]);
        NSLog([dateExploded objectAtIndex: 1]);
        NSLog([dateExploded objectAtIndex: 2]);
        NSLog([dateExploded objectAtIndex: 3]);
        NSLog([dateExploded objectAtIndex: 4]);
        NSLog([dateExploded objectAtIndex: 5]);
        
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 0] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_year"];

        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 1] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_month"];
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 2] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_day"];
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 3] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_hour"];
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 4] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_minute"];
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 5] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_ampm"];
        
        [formData appendPartWithFormData:[[_ecosystemTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"ecosystem-type"];
        
        
        
        
        
        
        
        
        
        
        // etc.
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@", operation.responseString);
        //I know this is in the error block. but because awisconsinbestiary doesn't return a valid response, the failure block is called.

        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        //Success
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation.response;
        int statuscode = response.statusCode;
        NSLog([NSString stringWithFormat:@"%i CHECHKING ERROR CODE",statuscode]);
        
        
        
        if(statuscode== 200) {
            //dismiss progrees
            //delete entry
            [self.navigationController popViewControllerAnimated:YES];
            
            
            if(_existingSubmission)
            {
                NSLog(@"YEAH ITS EXISTING SIGHTING");
                [self deleteObjectInCoreData];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Submission successfully submitted" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
            [alert show];
            
            
            
            //[self.tabBarController setSelectedIndex:0];
            [self clearFields];
        }else{
            //failure
            
            //dismiss progress
        }
        

        
        

    }];

    
    

 
    
}

- (void)submitWithCorrectDate {
    
    URL_FOR_SUBMISSION = @"http://awisconsinbestiary.org/submissions/";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [manager POST:URL_FOR_SUBMISSION parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"first-name"];
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"last-name"];
        [formData appendPartWithFormData:[[_emailTextField text] dataUsingEncoding:NSUTF8StringEncoding]
         
                                    name:@"replyto"];
        [formData appendPartWithFormData:[@"Bestiary Submission" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"topic"];
        if ([_affiliationSegControl selectedSegmentIndex] == 0) {
            [formData appendPartWithFormData:[@"other" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"school-affiliation"];
            
        } else if ([_affiliationSegControl selectedSegmentIndex] == 1) {
            [formData appendPartWithFormData:[@"other" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"school-affiliation"];
        }
        
        [formData appendPartWithFormData:[[_groupPhylaTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"animal"];
        [formData appendPartWithFormData:[[_commonNameTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"common-name"];
        [formData appendPartWithFormData:[[_speciesTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"species"];
        [formData appendPartWithFormData:[[_amountTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"how-many-of-this-animal-did-you-see"];
        [formData appendPartWithFormData:[[_behavioralTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"behavioral-description"];
        [formData appendPartWithFormData:[[_countyTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"county"];
        [formData appendPartWithFormData:[[_longitudeTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"logitude"];
        [formData appendPartWithFormData:[[_altitudeTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"altitude"];
        [formData appendPartWithFormData:[[_latitudeTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"latitude"];
        
        if ([_observationTechSegControl selectedSegmentIndex] == 0) {
            [formData appendPartWithFormData:[@"Casual" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"observation-technique-1"];
        } else if ([_observationTechSegControl selectedSegmentIndex] == 1) {
            [formData appendPartWithFormData:[@"Stationary" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"observation-technique-1"];
        }
        else if ([_observationTechSegControl selectedSegmentIndex] == 2) {
            [formData appendPartWithFormData:[@"Traveling" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"observation-technique-1"];
        }
        else if ([_observationTechSegControl selectedSegmentIndex] == 3) {
            [formData appendPartWithFormData:[@"Area" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"observation-technique-1"];
        }
        
        [formData appendPartWithFormData:[[_observationTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"observation-technique"];
        
        
        
        
        if(isnan(temperature)){
            [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"degrees-celcius"];
        }else{
            [formData appendPartWithFormData:[[[NSNumber numberWithFloat:temperature] stringValue] dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"degrees-celcius"];
        }
        
        if(isnan(windSpeed)){
            [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"wind-speed-mph"];
        }else{
            [formData appendPartWithFormData:[[[NSNumber numberWithFloat:windSpeed] stringValue] dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"wind-speed-mph"];
        }
        
        if(windDirection == nil){
            [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"wind-direction"];
        }else{
            [formData appendPartWithFormData:[windDirection dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"wind-direction"];
        }
        
        if(isnan(pressure)){
            [formData appendPartWithFormData:[ @"" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"pressure-mbar"];
        }else{
            [formData appendPartWithFormData:[[[NSNumber numberWithFloat:pressure] stringValue] dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"pressure-mbar"];
        }
        
        
        if(precipitationMeasure == nil){
            
            [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"precipitation-inches"];
        }else{
            
            [formData appendPartWithFormData:[[[NSNumber numberWithFloat:rain] stringValue] dataUsingEncoding:NSUTF8StringEncoding]
                                        name:@"precipitation-inches"];
        }
        
        
        
        
        
        
        //START HERE
        
        if(photoURL != nil){
            
            NSLog(@"PHOTO URL IS NOT NULL");
            NSLog([photoURL absoluteString]);
            NSLog(photoURL.path);
            
            
            
            if(_imageOutlet != nil){
                NSLog(@"IMAGE OUTLET IS NOT NULL");
                NSData *imageData = UIImagePNGRepresentation([_imageOutlet image]);
                
                if(imageData != nil){
                    NSLog(@"IMAGE DATA IS NOT NULL");
                    [formData appendPartWithFileData:imageData name:@"image-to-append_file" fileName:@"picture.png" mimeType:@"application/octet-stream"];
                }
                
            }
            
            
            
            
            NSError* error;
            
            
            if(error != nil){
                //ALERT ERROR HERE
                NSLog(@"BUT THERE WAS AN ERROR %@",error);
            }
            
            
        }
        
        if(audioData != nil){
            
            
            NSLog(@"AUDIO URL IS NOT NULL");
            
            
            [formData appendPartWithFileData:audioData name:@"audio_file" fileName:@"audio_file.m4a" mimeType:@"application/octet-stream"];
            

            
            
        }
        
        [formData appendPartWithFormData:[[_additionalTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"specific-text-you-would-like-used-to-acknowledge-photograph-interesting-anecdote-submission"];
        
        [formData appendPartWithFormData:[@"Submit" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"form_submit"];
        
        [formData appendPartWithFormData:[@"6b9ec1bdad9b1656f6ebf3720017d3c9118ed11f" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"_authenticator"];
        
        [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"form.submitted"];
        
        [formData appendPartWithFormData:[@"I agree" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"agreement:list"];
        
        [formData appendPartWithFormData:[@"default" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"fieldset"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd-hh-mm-a"];
        //Optionally for time zone converstions
        
        
        
        [formData appendPartWithFormData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken"];
        
        
        NSArray* dateExploded = [photoTime componentsSeparatedByString: @"-"];
        
        
        
        NSLog(@"time");
        NSLog(photoTime);

        
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 0] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_year"];
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 1] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_month"];
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 2] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_day"];
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 3] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_hour"];
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 4] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_minute"];
        [formData appendPartWithFormData:[[dateExploded objectAtIndex: 5] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"date-photo-was-taken_ampm"];
        
        
        [formData appendPartWithFormData:[[_ecosystemTextField text] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"ecosystem-type"];
        
        
        
        
        
        
        
        
        
        
        
        // etc.
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        //NSLog(@"Error: %@", operation.responseString);
        //I know this is in the error block. but because awisconsinbestiary doesn't return a valid response, the failure block is called.
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation.response;
        int statuscode = response.statusCode;
        NSLog([NSString stringWithFormat:@"%i CHECHKING ERROR CODE",statuscode]);
        
        
        if(statuscode== 200) {
            //dismiss progrees
            //delete entry
            [self.navigationController popViewControllerAnimated:YES];

            
            if(_existingSubmission)
            {
                NSLog(@"YEAH ITS EXISTING SIGHTING");
                [self deleteObjectInCoreData];

            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Submission successfully submitted" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil,nil];
            [alert show];
            

            
            //[self.tabBarController setSelectedIndex:0];
            [self clearFields];
        }else{
            //failure
            
            //dismiss progress
        }
        
        
    }];
    
    
    
    
    
    
}

-(void)deleteObjectInCoreData{
    NSLog(@"Here");
    NSError* error;
    [[self managedObjectContext] deleteObject:_existingSighting];
    if (![[self managedObjectContext]  save:&error]) {
        NSLog(@"Couldn't save 1 : %@", error);
    }
}





@end