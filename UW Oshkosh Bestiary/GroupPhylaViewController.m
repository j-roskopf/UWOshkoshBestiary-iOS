//
//  GroupPhylaViewController.m
//  Bestiary
//
//  Created by Joe on 5/11/14.
//  Copyright (c) 2014 UW Oshkosh. All rights reserved.
//

#import "GroupPhylaViewController.h"

@interface GroupPhylaViewController ()

@end

@implementation GroupPhylaViewController

{
    NSArray *groupPhylumNames;
    NSString *selectedGroup;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    groupPhylumNames = [NSArray arrayWithObjects:@"ameba",@"amphibians",@"birds",@"butterflies",@"centipedes",@"ciliates",@"crustacean",@"dragonflies",@"fish",@"flagellate",@"flatworm",@"hydra",@"leech",@"mammal",@"millipedes",@"mussels",@"meptile",@"motifer",@"slug/snails",@"sponge",@"ticks/spiders",@"unsure",nil];
    
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
    if (groupPhylumNames!=nil) {
        return [groupPhylumNames count];//this will tell the picker how many rows it has - in this case, the size of your loaded array...
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //you can also write code here to descide what data to return depending on the component ("column")
    if (groupPhylumNames!=nil) {
        return [groupPhylumNames objectAtIndex:row];//assuming the array contains strings..
    }
    return @"";//or nil, depending how protective you are
}
- (IBAction)saveGroup:(id)sender {
    
    selectedGroup = [groupPhylumNames objectAtIndex:[_pickerView selectedRowInComponent:0]];
    

    [_delegate groupChanged:selectedGroup];
    [self.navigationController popViewControllerAnimated:YES];
    
}



@end
