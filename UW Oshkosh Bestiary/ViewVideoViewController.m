//
//  ViewVideoViewController.m
//  UW Oshkosh Bestiary
//
//  Created by Joe on 6/18/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import "ViewVideoViewController.h"

@interface ViewVideoViewController ()

@end

@implementation ViewVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.videoController = [[MPMoviePlayerController alloc] init];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGFloat screenWidth = screenRect.size.width;
    //Calculates the height based off the screen's view minus the tab bar minus the nav bar and minus the status bar
    CGFloat screenHeight = screenRect.size.height - self.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height-statusBarSize.height;
    
    [self.videoController setContentURL:self.videoURL];
    [self.videoController.view setFrame:CGRectMake (0,self.navigationController.navigationBar.frame.size.height+statusBarSize.height, screenWidth, screenHeight)];
    [self.view addSubview:self.videoController.view];
    
    [self.videoController play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)receivedVideoUrl:(NSURL*)url
{
    _videoURL = url;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
