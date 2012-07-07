//
//  TwitterClient.h
//  Twitter List Reader
//
//  Created by Michael Koby on 11/28/11.
//  Copyright (c) 2011 Michael Koby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface TwitterClient : NSObject {
    NSDictionary *returnedTweets;
    NSArray *tweetItems;
}

+ (NSDictionary *)getListsForAccount:(ACAccount *)account;
+ (NSArray *)getTimelineForListWithId:(NSUInteger)listId forAccountWithIdentifier:(NSString *)accountIdentifier;
+ (NSMutableDictionary *)getRequestParamentersForListId:(NSString *)listId withOldestTweet:(NSString *)oldestTweet withLatestTweet:(NSString *)newestTweet;

@end
