//
//  TimelineViewController.h
//  Twitter List Reader
//
//  Created by Michael Koby on 11/29/11.
//  Copyright (c) 2011 Michael Koby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TweetItem.h"

@interface TimelineViewController : UITableViewController {
    NSArray *activeLists;
    NSArray *tweetItems;
    NSMutableDictionary *imageCache;
    TweetItem *selectedTweet;
}

@property (nonatomic, strong) NSArray *activeLists;
@property (nonatomic, strong) NSArray *tweetItems;
@property (nonatomic, strong) TweetItem *selectedTweet;

- (IBAction)refreshTimeline:(id)sender;

- (void)getTweetItemsForActiveLists;
- (ACAccountStore *)getApplicationAccountStore;
- (void)makeTwitterRequestForAccount:(ACAccount *)account withRequestParameters:(NSMutableDictionary *)requestParameters;

@end
