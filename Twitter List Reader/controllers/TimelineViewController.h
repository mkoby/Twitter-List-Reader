//
//  TimelineViewController.h
//  Twitter List Reader
//
//  Created by Michael Koby on 11/29/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface TimelineViewController : UITableViewController {
    NSArray *activeLists;
    NSMutableArray *tweetItems;
}

@property (nonatomic, strong) NSArray *activeLists;
@property (nonatomic, strong) NSMutableArray *tweetItems;

- (IBAction)refreshTimeline:(id)sender;

- (void)getTweetItemsForActiveLists;
- (ACAccountStore *)getApplicationAccountStore;
- (void)makeTwitterRequestForAccount:(ACAccount *)account toRequestURL:(NSString *)requestURL withRequestParameters:(NSMutableDictionary *)requestParameters;

@end
