//
//  TimelineViewController.h
//  Twitter List Reader
//
//  Created by Michael Koby on 11/29/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineViewController : UITableViewController {
    NSArray *activeLists;
    NSMutableArray *tweetItems;
}

@property (nonatomic, strong) NSArray *activeLists;
@property (nonatomic, strong) NSMutableArray *tweetItems;

- (void)getTweetItemsForActiveLists;
- (NSString *)getDateDifferenceForTweetDate:(NSDate *)tweetDate;

@end
