//
//  CountyViewController.h
//  Bestiary
//
//  Created by Joe on 5/11/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol CountyDelegate <NSObject>

@required
-(void)countyChanged:(NSString *) county;

@end



@interface CountyViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) id<CountyDelegate> delegate;


@end



