//
//  WeatherViewController.h
//  UW Oshkosh Bestiary
//
//  Created by Joe on 6/14/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>
#import <AFHTTPRequestOperationManager.h>

@protocol WeatherChangedAfterError <NSObject>

@required
-(void)weatherSavedAfterError:(float) r withDegrees :(float) degrees withWindSpeed:(float)windSp withWindDirection:(NSString*) windDir withPressure:(float) press withPrecipitationMeasure:(NSString*) precipMeasure;

@end


@interface WeatherViewController : UIViewController<CLLocationManagerDelegate>

-(void)weatherSaved:(float) rain withDegrees :(float) degrees withWindSpeed:(float)windSpeed withWindDirection:(NSString*) windDirection withPressure:(float) pressure withPrecipitationMeasure:(NSString*) measure;




@property (weak, nonatomic) IBOutlet UILabel *windSpeed;
@property (weak, nonatomic) IBOutlet UILabel *windDirection;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UILabel *pressure;
@property (weak, nonatomic) IBOutlet UILabel *precipitation;
@property (weak, nonatomic) IBOutlet UILabel *precipitationHeader;

@property (nonatomic, assign) BOOL existingSubmission;
@property (nonatomic, assign) BOOL errorCollectingWeather;


@property (strong, nonatomic) id<WeatherChangedAfterError> delegate;


@end


