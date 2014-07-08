//
//  GroupPhylaViewController.h
//  Bestiary
//
//  Created by Joe on 5/11/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupDelegate <NSObject> //1 @required

@required

-(void)groupChanged:(NSString *) group;

@end //2

@interface GroupPhylaViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) id<GroupDelegate> delegate;


@end




