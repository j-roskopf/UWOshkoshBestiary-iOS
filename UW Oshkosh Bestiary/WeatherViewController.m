//
//  WeatherViewController.m
//  UW Oshkosh Bestiary
//
//  Created by Joe on 6/14/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import "WeatherViewController.h"
#import "FirstViewController.h"

@interface WeatherViewController ()
@property (weak, nonatomic) IBOutlet UIButton *collectWeatherButton;




@end

CLLocationManager *locationManager;


@implementation WeatherViewController
{
    float temperature;
    float windSp;
    float press;
    NSString *windDir;
    float precipitation;
    NSString *precipitationMeasure;
    UIAlertView *alert;
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



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self refreshTitles];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)weatherSaved:(float)rain withDegrees:(float)degrees withWindSpeed:(float)windSpeed withWindDirection:(NSString*)windDirection withPressure:(float)pressure withPrecipitationMeasure:(NSString*)measure
{
    precipitation = rain;
    temperature = degrees;
    windDir = windDirection;
    windSp = windSpeed;
    press = pressure;
    precipitationMeasure = measure;


}
- (IBAction)collectWeatherManually:(id)sender {
    //Disables button
    _collectWeatherButton.enabled = FALSE;
    [_collectWeatherButton setTitle: @"Collecting" forState:UIControlStateNormal];
    _collectWeatherButton.enabled = TRUE;

    
    if(locationManager == nil)
        locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.distanceFilter = 100;
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *location = [locations lastObject];
    
    CLLocationCoordinate2D coordinate= location.coordinate;
    
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
                 _temperature.text = [NSString stringWithFormat:@"%f",(temperature)];

                 NSString *tempWindSpeed = responseObject[@"wind"][@"speed"];
                 windSp = [tempWindSpeed floatValue];
                 _windSpeed.text = [NSString stringWithFormat:@"%f",windSp];

                 NSString *tempWindDegrees = responseObject[@"wind"][@"deg"];
                 windDir = [self windDirectionForDegrees:[tempWindDegrees floatValue]];
                 _windDirection.text = windDir;

                 NSString *tempPressure = responseObject[@"main"][@"pressure"];
                 press = [tempPressure floatValue];
                 _pressure.text = [NSString stringWithFormat:@"%f",press];

                 //Open weather can return three different formats for rain
                 NSString *rain1 = responseObject[@"rain"][@"1h"];
                 NSString *rain2 = responseObject[@"rain"][@"2h"];
                 NSString *rain3 = responseObject[@"rain"][@"3h"];
                 
                 precipitation;
                 if(rain1 == nil && rain2 == nil)
                 {
                     precipitation = [rain3 floatValue];
                     precipitationMeasure = @"3h";
                 }
                 else if (rain2 == nil && rain3 == nil)
                 {
                     precipitation = [rain1 floatValue];
                     precipitationMeasure = @"1h";
                     
                     
                 }
                 else if (rain3 == nil && rain1 == nil)
                 {
                     precipitation = [rain2 floatValue];
                     precipitationMeasure = @"2h";
                     
                 }
                 
                 //Making sure rainToUse isn't nil
                 if(!precipitation)
                 {
                     precipitation = 0.0;
                 }
                 
                 _precipitation.text = [NSString stringWithFormat:@"%f",precipitation];
                 _precipitationHeader.text = [NSString stringWithFormat:@"Precipitation in MM per %@",precipitationMeasure];
                 
                 _errorCollectingWeather = NO;
                 
                 [_collectWeatherButton setEnabled:YES];
                 
                 [_collectWeatherButton setTitle:@"Collect Weather Manually" forState:UIControlStateNormal]; // To set the title
                 
                 [_delegate weatherSavedAfterError:precipitation withDegrees:temperature withWindSpeed:windSp withWindDirection:windDir withPressure:press withPrecipitationMeasure:precipitationMeasure];
                 
                 [self refreshTitles];
                 
                 
                 
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 
                 UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Internet Error"
                                                                   message:@"There has been an error. No weather data will be collected"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                 
                 [message show];
                 
                 _errorCollectingWeather = YES;
                 [_collectWeatherButton setEnabled:YES];

                 [_collectWeatherButton setTitle: @"" forState: UIControlStateDisabled];
                 [_collectWeatherButton setTitle: @"Error collecting, try again" forState: UIControlStateNormal];
                 
                 [self refreshTitles];
                 


             }];



    
}

-(void)refreshTitles
{
    if(_errorCollectingWeather)
    {
        _temperature.text = @"Error collecting";
        _windSpeed.text = @"Error collecting";
        _windDirection.text = @"Error collecting";
        _pressure.text = @"Error collecting";
        _precipitation.text = @"Error collecting";
        _precipitationHeader.text = @"Error collecting";
    }
    else
    {
        _temperature.text = [NSString stringWithFormat:@"%f",(temperature)];
        _windSpeed.text = [NSString stringWithFormat:@"%f",windSp];
        _windDirection.text = windDir;
        _pressure.text = [NSString stringWithFormat:@"%f",press];;
        _precipitation.text = [NSString stringWithFormat:@"%f",precipitation];
        _precipitationHeader.text = [NSString stringWithFormat:@"Precipitation in MM per %@",precipitationMeasure];
    }

}
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    if(alert == nil)
    {
        NSLog(@"Here");
        NSString *message;
        
        switch([error code])
        {
            case kCLErrorNetwork: // general, network-related error
            {
                message = @"Please check your network connection or that you are not in airplane mode";
            }
                break;
            case kCLErrorDenied:{
                message = @"User has denied to use current location";
            }
                break;
            default:
            {
                message = @"Internet connection error";
            }
                break;
        }
        
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    }



    [_collectWeatherButton setTitle: @"Collect Weather Manually" forState:UIControlStateNormal];

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
