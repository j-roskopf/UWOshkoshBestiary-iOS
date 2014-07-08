//
//  CountyViewController.m
//  Bestiary
//
//  Created by Joe on 5/11/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import "CountyViewController.h"

@interface CountyViewController ()

@end

@implementation CountyViewController
{
    NSArray *countyNames;
    NSString *selectedCounty;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    countyNames = [NSArray arrayWithObjects:@"Adams",@"Ashland",@"Barron",@"Bayfield",@"Brown",@"Buffalo",@"Burnett",@"Calumet",@"Chippewa",@"Clark",@"Columba",@"Crawford",@"Dane",@"Dodge",@"Door",@"Douglan",@"Dunn",@"Eau Claire",@"Florence",@"Fond du Lac",@"Forest",@"Grant",@"Green",@"Green Lake",@"Iowa",@"Iron",@"Jackson",@"Jefferson",@"Juneau",@"Kenosha",@"Kewaunee",@"LaCrosse",@"Lafayette",@"Langlade",@"Lincoln",@"Manitowoc",@"Marathon",@"Marinette",@"Marquette",@"Menominee",@"Milwaukee",@"Monroe",@"Oconto",@"Oneida",@"Outagamie",@"Ozaukee",@"Pepin",@"Pierce",@"Polk",@"Portage",@"Price",@"Racine",@"Richland",@"Rock",@"Rusk",@"Saint Croix",@"Sauk",@"Sawyer",@"Shawano",@"Sheboygan",@"Taylor",@"Trempealeau",@"Vernon",@"Vilas",@"Walworth",@"Washburn",@"Washington",@"Waukesha",@"Waupaca",@"Waushara",@"Winnebago",@"Wood",nil];
    
    _pickerView.dataSource = self;
    _pickerView.delegate = self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;// or the number of vertical "columns" the picker will show...
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (countyNames!=nil) {
        return [countyNames count];//this will tell the picker how many rows it has - in this case, the size of your loaded array...
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //you can also write code here to descide what data to return depending on the component ("column")
    if (countyNames!=nil) {
        return [countyNames objectAtIndex:row];//assuming the array contains strings..
    }
    return @"";//or nil, depending how protective you are
}


- (IBAction)saveCounty:(id)sender {
    selectedCounty = [countyNames objectAtIndex:[_pickerView selectedRowInComponent:0]];

    [_delegate countyChanged:selectedCounty];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
