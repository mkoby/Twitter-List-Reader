//
//  AccountListsViewController.m
//  Twitter List Reader
//
//  Created by Michael Koby on 11/30/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import "AccountListsViewController.h"
#import "TwitterList.h"
#import "FMDBDataAccess.h"

@implementation AccountListsViewController

@synthesize listsTable;
@synthesize account, accountIdentifier, listsData, accountLists, sortedKeys;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getListsForAccount:self.account];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.account = nil;
    self.accountIdentifier = nil;
    self.accountLists = nil;
    self.sortedKeys = nil;
    self.listsData = nil;
    self.listsTable = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)turnOnList:(id)sender {
}

- (void)getListsForAccount:(ACAccount *)twitterAccount {
    if (twitterAccount == nil)
        return;
    
    self.accountIdentifier = twitterAccount.identifier;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"1" forKey:@"include_rts"];
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/lists/all.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url 
                                             parameters:params 
                                          requestMethod:TWRequestMethodGET];
    [request setAccount:twitterAccount];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barButton = 
    [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [[self navigationItem] setRightBarButtonItem:barButton];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator startAnimating];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error);
            return;
        }
        
        if ([urlResponse statusCode] == 200) {
            NSError *jsonError;
            listsData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
            if (listsData.count > 0) {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_group_t process_group = dispatch_group_create();
                
                dispatch_sync(queue, ^{
                    NSMutableArray *lists = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *list in listsData) {
                        [lists addObject:[[TwitterList alloc] initWithAttributes:list]];
                    }
                    
                    self.accountLists = [TwitterList createNSDictionaryOfListsFromNSArray:lists];
                    self.sortedKeys =[[self.accountLists allKeys] sortedArrayUsingSelector:@selector(compare:)];
                });
                
                dispatch_group_wait(process_group, DISPATCH_TIME_FOREVER);    
                dispatch_release(process_group);
                
                [activityIndicator stopAnimating];
                [self performSelectorOnMainThread:@selector(updateTable) withObject:NULL waitUntilDone:NO];
            } else {
                [activityIndicator stopAnimating];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Lists" message:@"This account is not following any lists." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        } else {
            NSLog(@"Response Code: %i", [urlResponse statusCode]);
        }
    }];
}

- (void)updateTable {
    [self.listsTable reloadData];
}

- (void)changeState:(id)sender {    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UISwitch *selectedSwitch = (UISwitch *)sender;
        UITableViewCell *cell = (UITableViewCell *)selectedSwitch.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSInteger row = [indexPath row];
        NSArray *listData =[self.accountLists objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]];
        TwitterList *listItem = [listData objectAtIndex:row];
        FMDBDataAccess *dataAccess = [[FMDBDataAccess alloc] init];
        
        //NSLog(@"\nAccount Identifier: %@\nList ID: %d", self.accountIdentifier, (int)listItem.listId);
        
        if (selectedSwitch.isOn) {
            [dataAccess addListID:listItem.listId forAccountIdentifier:self.accountIdentifier];
        } else if (selectedSwitch.isOn == NO) {
            [dataAccess removeListID:listItem.listId forAccountIdentifier:self.accountIdentifier];
        }
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sortedKeys count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sortedKeys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *listData =[self.accountLists objectForKey:[self.sortedKeys objectAtIndex:section]];
    return [listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *listData =[self.accountLists objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]];
    static NSString *CellIdentifier = @"AccountListCellIdentifier";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = [indexPath row];
    TwitterList *listItem = [listData objectAtIndex:row];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    nameLabel.text = listItem.name;
    
    __block UISwitch *downloadSwitch = (UISwitch *)[cell viewWithTag:2];
    [cell setAccessoryView:downloadSwitch];
    [(UISwitch *)cell.accessoryView addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventValueChanged];
    downloadSwitch.enabled = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDBDataAccess *dataAccess = [[FMDBDataAccess alloc] init];
        BOOL isOn = [dataAccess isList:listItem.listId activeForAccountIdentifier:self.accountIdentifier];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [downloadSwitch setOn:isOn animated:YES];
        });
    });
    
    return cell;
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];    
    UISwitch *theSwitch = (UISwitch *)cell.accessoryView;
    
    if (theSwitch.isOn) {
        [theSwitch setOn:NO animated:YES];
    } else if (theSwitch.isOn == NO) {
        [theSwitch setOn:YES animated:YES];
    }
    
    [self performSelector:@selector(changeState:) withObject:theSwitch];
    
    //Deselect this row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonPressed = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonPressed isEqualToString:@"OK"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
