//
//  TimelineViewController.m
//  Twitter List Reader
//
//  Created by Michael Koby on 11/29/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import "TimelineViewController.h"
#import "FMDBDataAccess.h"
#import "TwitterClient.h"
#import "TweetItem.h"

@implementation TimelineViewController
@synthesize activeLists, tweetItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    FMDBDataAccess *dataAccess = [[FMDBDataAccess alloc] init];
    self.activeLists = [dataAccess getActiveLists];
    [self getTweetItemsForActiveLists];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)getTweetItemsForActiveLists {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ACAccountStore *accounts = appDelegate.accountStore;
    self.tweetItems = [[NSMutableArray alloc] init];
    
    for (NSDictionary *list in self.activeLists) {
        ACAccount *account = [accounts accountWithIdentifier:[list valueForKeyPath:@"AccountIdentifier"]];
        NSString *listsURL = @"https://api.twitter.com/1/lists/statuses.json";
        NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
        NSNumber *listidnumber = [list valueForKeyPath:@"ListID"];
        NSString *listIdAsString = [[NSString alloc] initWithFormat:@"%d", [listidnumber unsignedIntValue]];
        [requestParameters setObject:listIdAsString forKey:@"list_id"];
        [requestParameters setObject:@"1" forKey:@"include_rts"];
        TWRequest *listsRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:listsURL] 
                                                      parameters:requestParameters 
                                                   requestMethod:TWRequestMethodGET];
        listsRequest.account = account;
        
        [listsRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if ([urlResponse statusCode] == 200) 
            {
                // The response from Twitter is in JSON format
                // Move the response into a dictionary and print
                NSError *error;        
                NSDictionary *returnedTweets = nil;
                returnedTweets = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                
                if (returnedTweets != nil) {
                    for (NSDictionary *tweet in returnedTweets) {
                        //NSLog(@"%@", tweet);
                        TweetItem *item = [[TweetItem alloc] initWithAttributes:tweet];
                        //NSLog(@"\n%@\n%@\n%@", item.username, item.tweet, item.imageURL);
                        [self.tweetItems addObject:item];
                    }
                    
                    [self performSelectorInBackground:@selector(processTweetItems) withObject:nil];
                }
                //NSLog(@"Twitter response: %@", returnedTweets);
            }
            else
                NSLog(@"Twitter error, HTTP response: %i", [urlResponse statusCode]);
        }];
    }
}

- (void)processTweetItems {
    NSLog(@"%d", self.tweetItems.count);
    
    __block NSArray *sortedArray;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t process_group = dispatch_group_create();
    
    dispatch_async(queue, ^{        
        __block NSDateFormatter* df = nil;
        
        df = [[NSDateFormatter alloc] init];
        [df setTimeStyle:NSDateFormatterFullStyle];
        [df setFormatterBehavior:NSDateFormatterBehavior10_4];
        [df setDateFormat:@"EEE MMM dd HH:mm:ss ZZZZ yyyy"];
        
        sortedArray = [self.tweetItems sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate *first = [(TweetItem *)a tweetDate];
            NSDate *second = [(TweetItem *)b tweetDate];
            return [first compare:second];
        }];
        
        sortedArray = [[sortedArray reverseObjectEnumerator] allObjects];
        self.tweetItems = [[NSMutableArray alloc] initWithArray:sortedArray];
    });
    
    dispatch_group_wait(process_group, DISPATCH_TIME_FOREVER);    
    dispatch_release(process_group); 
    
    //TODO: Remove duplicates, not now but will add later
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UITableView DataSource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweetItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *TweetItemCellIdentifier = @"TweetItemCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TweetItemCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TweetItemCellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    TweetItem *tweet = [self.tweetItems objectAtIndex:row];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    nameLabel.text = tweet.username;
    
    UILabel *tweetLabel = (UILabel *)[cell viewWithTag:4];
    tweetLabel.text = tweet.tweet;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tweet.imageURL]]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIImageView *avatarImageView = (UIImageView *)[cell viewWithTag:1];
            avatarImageView.image = avatarImage;
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:8];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            timeLabel.text = [tweet getDateDifferenceForTweetDate];
        });
    });
    
    return cell;
}

@end
