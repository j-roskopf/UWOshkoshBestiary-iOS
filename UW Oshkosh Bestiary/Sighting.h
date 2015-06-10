//
//  Sighting.h
//  UW Oshkosh Bestiary
//
//  Created by Administator on 7/10/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Sighting : NSManagedObject

@property (nonatomic, retain) NSString * additionalInformation;
@property (nonatomic, retain) NSString * affiliation;
@property (nonatomic, retain) NSString * altitude;
@property (nonatomic, retain) NSString * amount;
@property (nonatomic, retain) NSData * audioData;
@property (nonatomic, retain) NSString * audioUrl;
@property (nonatomic, retain) NSString * behavorialDescription;
@property (nonatomic, retain) NSString * commonName;
@property (nonatomic, retain) NSString * county;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * ecosystem;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * observationalTechniqueOther;
@property (nonatomic, retain) NSNumber * precipitation;
@property (nonatomic, retain) NSString * precipitationMeasure;
@property (nonatomic, retain) NSNumber * pressure;
@property (nonatomic, retain) NSString * privacy;
@property (nonatomic, retain) NSString * species;
@property (nonatomic, retain) NSString * technique;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSString * videoUrl;
@property (nonatomic, retain) NSString * windDirection;
@property (nonatomic, retain) NSNumber * windSpeed;
@property (nonatomic, retain) NSString * photoTime;
@property (nonatomic, retain) NSString * videoTime;
@property (nonatomic, retain) NSString * photoUrl;

@end
