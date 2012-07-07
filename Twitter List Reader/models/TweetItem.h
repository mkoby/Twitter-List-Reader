//
//  TweetItem.h
//  Find Tweets
//
//  Created by Michael Koby on 10/24/11.
//  Copyright (c) 2011 Michael Koby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetItem : NSObject {
    NSString *tweetId;
    NSString *username;
    NSString *tweet;
    NSString *imageURL;
    NSDate *tweetDate;
}

@property (nonatomic, strong) NSString *tweetId;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *tweet;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSDate *tweetDate;

- (TweetItem *)initWithAttributes:(NSDictionary *)attributes;
- (NSString *)getUserDataFromUserAttributes:(NSDictionary *)attributes forKeyValue:(NSString *)keyValue;
- (NSString *)getDateDifferenceForTweetDateWithFullUnitsText:(BOOL)fullText;

+ (NSArray *)sortTweets:(NSArray *)tweets;
+ (NSArray *)addTweets:(NSArray *)newTweets to:(NSArray *)tweets;

@end
