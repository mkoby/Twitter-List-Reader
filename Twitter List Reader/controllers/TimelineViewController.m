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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    FMDBDataAccess *dataAccess = [[FMDBDataAccess alloc] init];
    self.activeLists = [dataAccess getActiveLists];
    
    if (self.activeLists.count > 0) {
        [self performSelector:@selector(_loadTimeline)];
    } else {
        self.tabBarController.selectedIndex = 1; //Goto settings Tab if nothing no lists in DB
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.tweetItems = nil;
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

- (void)_loadTimeline {
    [self getTweetItemsForActiveLists];
}

- (IBAction)refreshTimeline:(id)sender {
    [self performSelectorInBackground:@selector(_refreshTimeline) withObject:nil];
//    [self performSelector:@selector(_refreshTimeline)];
}

- (ACAccountStore *)getApplicationAccountStore {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ACAccountStore *accounts = appDelegate.accountStore;
    
    return accounts;
}

- (void)makeTwitterRequestForAccount:(ACAccount *)account toRequestURL:(NSString *)requestURL withRequestParameters:(NSMutableDictionary *)requestParameters {
    [requestParameters setObject:@"1" forKey:@"include_rts"]; //Always use RTS since we're ALWAYS tied to an account
    TWRequest *twitterRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:requestURL] 
                                                  parameters:requestParameters 
                                               requestMethod:TWRequestMethodGET];
    twitterRequest.account = account;
    
    [twitterRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) 
        {
            // The response from Twitter is in JSON format
            // Move the response into a dictionary and print
            NSError *error;        
            NSDictionary *returnedTweets = nil;
            returnedTweets = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            NSMutableArray *tweets = [[NSMutableArray alloc] init];
            
            if (returnedTweets != nil) {
                for (NSDictionary *tweet in returnedTweets) {
                    //NSLog(@"%@", tweet);
                    TweetItem *item = [[TweetItem alloc] initWithAttributes:tweet];
                    //NSLog(@"\n%@\n%@\n%@", item.username, item.tweet, item.imageURL);
                    [tweets addObject:item];
                }
                
                [self performSelectorInBackground:@selector(_processTweetItems:) withObject:tweets];
            }
            //NSLog(@"Twitter response: %@", returnedTweets);
        }
        else
            NSLog(@"Twitter error, HTTP response: %i", [urlResponse statusCode]);
    }];
}

- (void)getTweetItemsForActiveLists {
    ACAccountStore *accounts = [self getApplicationAccountStore];
    
    for (NSDictionary *list in self.activeLists) {
        ACAccount *account = [accounts accountWithIdentifier:[list valueForKeyPath:@"AccountIdentifier"]];
        NSString *listsURL = @"https://api.twitter.com/1/lists/statuses.json";
        NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
        NSNumber *listidnumber = [list valueForKeyPath:@"ListID"];
        NSString *listIdAsString = [[NSString alloc] initWithFormat:@"%d", [listidnumber unsignedIntValue]];
        [requestParameters setObject:listIdAsString forKey:@"list_id"];
        
        [self makeTwitterRequestForAccount:account toRequestURL:listsURL withRequestParameters:requestParameters];
    }
}

- (void)_refreshTimeline {
    ACAccountStore *accounts = [self getApplicationAccountStore];
    TweetItem *newestTweet = [self.tweetItems objectAtIndex:0];
    
    for (NSDictionary *list in self.activeLists) {
        ACAccount *account = [accounts accountWithIdentifier:[list valueForKeyPath:@"AccountIdentifier"]];
        NSString *listsURL = @"https://api.twitter.com/1/lists/statuses.json";
        NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
        NSNumber *listidnumber = [list valueForKeyPath:@"ListID"];
        NSString *listIdAsString = [[NSString alloc] initWithFormat:@"%d", [listidnumber unsignedIntValue]];
        [requestParameters setObject:listIdAsString forKey:@"list_id"];
        [requestParameters setObject:newestTweet.tweetId forKey:@"since_id"];
        
        [self makeTwitterRequestForAccount:account toRequestURL:listsURL withRequestParameters:requestParameters];
    }
    
}

- (void)_loadOlderTweets {
    ACAccountStore *accounts = [self getApplicationAccountStore];
    TweetItem *oldestTweet = [self.tweetItems lastObject];
    
    for (NSDictionary *list in self.activeLists) {
        ACAccount *account = [accounts accountWithIdentifier:[list valueForKeyPath:@"AccountIdentifier"]];
        NSString *listsURL = @"https://api.twitter.com/1/lists/statuses.json";
        NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
        NSNumber *listidnumber = [list valueForKeyPath:@"ListID"];
        NSString *listIdAsString = [[NSString alloc] initWithFormat:@"%d", [listidnumber unsignedIntValue]];
        [requestParameters setObject:listIdAsString forKey:@"list_id"];
        [requestParameters setObject:oldestTweet.tweetId forKey:@"max_id"];
        
        [self makeTwitterRequestForAccount:account toRequestURL:listsURL withRequestParameters:requestParameters];
    }
}

- (void)sortTweets {
    __block NSArray *sortedArray;
    __block NSDateFormatter* df = nil;
    
    df = [[NSDateFormatter alloc] init];
    [df setTimeStyle:NSDateFormatterFullStyle];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"EEE MMM dd HH:mm:ss ZZZZ yyyy"];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t process_group = dispatch_group_create();
    
    dispatch_async(queue, ^{        
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
}

- (void)addTweetsToTweetItems:(NSArray *)tweets {
    if (self.tweetItems == nil) {
        self.tweetItems = [[NSMutableArray alloc] init];
    }
    
    
    for (TweetItem *tweet in tweets) {
        NSString *currentId = tweet.tweetId;
        BOOL hasTweet = NO;
        
        for (TweetItem *storedTweet in self.tweetItems) {
            if ([storedTweet.tweetId isEqualToString:currentId]) {
                hasTweet = YES;
            }
        }
        
        if (!hasTweet) {
            [self.tweetItems addObject:tweet];
        }
    }
    
    [self sortTweets];
}

- (void)_processTweetItems:(NSMutableArray *)tweets {
    [self addTweetsToTweetItems:tweets];
    [self.tableView reloadData];
    self.tableView.hidden = NO;
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
    
    float currentRow = (float)row;
    float totalRows = (float)self.tweetItems.count;
    
    if ((currentRow / totalRows) > .85) {
        [self performSelectorInBackground:@selector(_loadOlderTweets) withObject:nil];
    }
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
