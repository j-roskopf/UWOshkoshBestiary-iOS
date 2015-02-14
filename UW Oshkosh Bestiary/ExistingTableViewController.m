//
//  SecondTableViewController.m
//
//
//  Created by Joe on 6/15/14.
//
//

#import "ExistingTableViewController.h"
#import "AppDelegate.h"
#import "Sighting.h"
#import "FirstViewController.h"

@interface ExistingTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ExistingTableViewController
{
    NSArray *submissions;
    NSMutableArray *mutableArray;
    int rowSelected;
    FirstViewController *firstViewController;
    NSManagedObjectContext *context;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    
    [self.tableView addGestureRecognizer:lpgr];
    
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [mutableArray count];}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SightingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    Sighting *s = [mutableArray objectAtIndex:[indexPath row]];
    
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[s date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    
    
    //Store selected row to pass to the first view controller
    rowSelected = indexPath.row;
    
    cell.textLabel.text = dateString;

    cell.detailTextLabel.text = [s group];
    
    UIImage *image = [UIImage imageWithData:[s image]];
    
    if(image != nil)
    {
        cell.imageView.image = image;

    }

    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ExistingSubmission"]) {
        
        firstViewController = segue.destinationViewController;
        firstViewController.existingSubmission = YES;
        
        
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    firstViewController.existingSighting = [mutableArray objectAtIndex:indexPath.row];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self reloadData];
    [self.tableView reloadData];

}

-(void)reloadData
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    context = [appDelegate managedObjectContext];
    
    // Grabs all the Sightings
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Sighting" inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:entity];
    
    NSError *error;
    
    submissions = [[NSArray alloc]initWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    
    mutableArray = [(NSArray*)submissions mutableCopy];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer


{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Detected long press"
                                                          message:@"There has been an error. No weather data will be collected"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        
        
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if (indexPath == nil) {
            NSLog(@"long press on table view but not on a row");
        } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            NSLog(@"long press on table view at row %d", indexPath.row);
        } else {
            NSLog(@"gestureRecognizer.state = %d", gestureRecognizer.state);
        }
        
    }

}





/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
