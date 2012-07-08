//
//  TimelineViewController.m
//  Twitter List Reader
//
//  Created by Michael Koby on 11/29/11.
//  Copyright (c) 2011 Michael Koby. All rights reserved.
//

#import "TimelineViewController.h"
#import "FMDBDataAccess.h"
#import "TwitterClient.h"
#import "TweetItem.h"
#import "SingleTweetViewController.h"

@implementation TimelineViewController
@synthesize activeLists, tweetItems, selectedTweet;

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
    NSLog(@"Received memory warning");
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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    imageCache = [NSMutableDictionary dictionary];
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
    
    NSLog(@"View is unloading");
    imageCache = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.activeLists = nil;
    self.tweetItems = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SingleTweetViewController *stvc = (SingleTweetViewController *)[segue destinationViewController];
    UITableViewCell *selectedCell = (UITableViewCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:selectedCell];
    NSInteger row = [indexPath row];
    stvc.selectedTweet = [self.tweetItems objectAtIndex:row];
    
    UIImageView *avatarImageView = (UIImageView *)[selectedCell viewWithTag:1];
    stvc.avatarImage = [avatarImageView image];
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
}

- (ACAccountStore *)getApplicationAccountStore {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ACAccountStore *accounts = appDelegate.accountStore;
    
    return accounts;
}

- (void)makeTwitterRequestForAccount:(ACAccount *)account withRequestParameters:(NSMutableDictionary *)requestParameters {
    NSString *listsURL = @"https://api.twitter.com/1/lists/statuses.json";
    [requestParameters setObject:@"1" forKey:@"include_rts"]; //Always use RTS since we're ALWAYS tied to an account
    TWRequest *twitterRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:listsURL] 
                                                  parameters:requestParameters 
                                               requestMethod:TWRequestMethodGET];
    twitterRequest.account = account;
    
    //Move Twitter specific stuff to Twitter API handling model
    //Leave View Controller stuff here.
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
                
                [self performSelector:@selector(_processTweetItems:) withObject:tweets];
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
        NSMutableDictionary *requestParameters = [TwitterClient getRequestParamentersForListId:[[NSString alloc] initWithFormat:@"%d", [[list valueForKeyPath:@"ListID"] unsignedIntValue]] withOldestTweet:nil withLatestTweet:nil];
        
        [self makeTwitterRequestForAccount:account withRequestParameters:requestParameters];
    }
}

- (void)_refreshTimeline {
    ACAccountStore *accounts = [self getApplicationAccountStore];
    TweetItem *newestTweet = [self.tweetItems objectAtIndex:0];
    
    for (NSDictionary *list in self.activeLists) {
        ACAccount *account = [accounts accountWithIdentifier:[list valueForKeyPath:@"AccountIdentifier"]];        
        NSMutableDictionary *requestParameters = [TwitterClient getRequestParamentersForListId:[[NSString alloc] initWithFormat:@"%d", [[list valueForKeyPath:@"ListID"] unsignedIntValue]] withOldestTweet:nil withLatestTweet:( newestTweet ? newestTweet.tweetId : nil ) ];
        
        [self makeTwitterRequestForAccount:account withRequestParameters:requestParameters];
    }
    
}

- (void)_loadOlderTweets {
    ACAccountStore *accounts = [self getApplicationAccountStore];
    TweetItem *oldestTweet = [self.tweetItems lastObject];
    
    for (NSDictionary *list in self.activeLists) {
        ACAccount *account = [accounts accountWithIdentifier:[list valueForKeyPath:@"AccountIdentifier"]];        
        NSMutableDictionary *requestParameters = [TwitterClient getRequestParamentersForListId:[[NSString alloc] initWithFormat:@"%d", [[list valueForKeyPath:@"ListID"] unsignedIntValue]] withOldestTweet:oldestTweet.tweetId withLatestTweet:nil ];
        
        [self makeTwitterRequestForAccount:account withRequestParameters:requestParameters];
    }
}

- (void)_processTweetItems:(NSMutableArray *)tweets {
    NSArray *newTweetItemsArray = [TweetItem addTweets:tweets to:self.tweetItems];
    NSArray *sortedTweets = [TweetItem sortTweets:newTweetItemsArray];
    self.tweetItems = sortedTweets;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        self.tableView.hidden = NO; 
    });
}

- (void)_getImageWithURL:(NSString *)url withRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *avatarImage = [UIImage imageWithData:imageData];
        [imageCache setObject:avatarImage forKey:indexPath];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
        });
    });
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
    
    if ([imageCache objectForKey:indexPath]) {
        UIImage *image = [imageCache objectForKey:indexPath];
        cell.imageView.image = image;
    } else {
        cell.imageView.image = nil;
        [self _getImageWithURL:tweet.imageURL
            withRowAtIndexPath:indexPath];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:8];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            timeLabel.text = [tweet getDateDifferenceForTweetDateWithFullUnitsText:NO];
        });
    });
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    self.selectedTweet = [self.tweetItems objectAtIndex:row];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self performSelector:@selector(_loadOlderTweets) withObject:nil];
        });
    }
}

@end
