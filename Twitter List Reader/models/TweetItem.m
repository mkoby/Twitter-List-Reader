//
//  TweetItem.m
//  Find Tweets
//
//  Created by Michael Koby on 10/24/11.
//  Copyright (c) 2011 Michael Koby. All rights reserved.
//

#import "TweetItem.h"

@implementation TweetItem

@synthesize username, tweet, imageURL, tweetId, tweetDate;

- (TweetItem *)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    
    if (!self)
        return nil;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE MMM dd HH:mm:ss ZZZZ yyyy"];  //set the format that matches Twitter's result…
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [df setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    self.tweetId = [attributes valueForKey:@"id_str"];
    self.username = [self getUserDataFromUserAttributes:[attributes valueForKeyPath:@"user"] forKeyValue:@"screen_name"]; 
    self.imageURL = [self getUserDataFromUserAttributes:[attributes valueForKeyPath:@"user"] forKeyValue:@"profile_image_url_https"];
    self.tweet = [attributes valueForKeyPath:@"text"];
    self.tweetDate = [df dateFromString:[attributes valueForKeyPath:@"created_at"]];
    
    //NSLog(@"%@\n%@\n%@", self.username, self.tweet, self.imageURL);
    
    return self;
}

- (NSString *)getUserDataFromUserAttributes:(NSDictionary *)attributes forKeyValue:(NSString *)keyValue {
    return [attributes valueForKeyPath:keyValue];
}

- (NSString *)getDateDifferenceForTweetDateWithFullUnitsText:(BOOL)fullText {
    NSString *amount = @"";
    double secondsSinceTweet = [self.tweetDate timeIntervalSinceNow];
    int secondsInInt = (int)(secondsSinceTweet * -1);
    NSString *unitText = @"";
    
    if (secondsInInt < 60) {
        if (fullText)
            unitText = @" seconds";
        else
            unitText = @"s";
        
        amount = [[NSString alloc] initWithFormat:@"%d%@", secondsInInt, unitText];
    } else if (secondsInInt > 60 && secondsInInt < 3600) {
        if (fullText)
            unitText = @" minutes";
        else
            unitText = @"m";
        
        amount = [[NSString alloc] initWithFormat:@"%d%@", (secondsInInt / 60), unitText];
    } else if (secondsInInt > 3600 && secondsInInt < 86400) {
        if (fullText)
            unitText = @" hours";
        else
            unitText = @"h";
        
        amount = [[NSString alloc] initWithFormat:@"%d%@", (secondsInInt / 3600), unitText];
    } else if(secondsInInt > 86400) {
        amount = [[NSString alloc] initWithFormat:@"%d days", (secondsInInt / 86400)];
    }
    
    NSString *timeAgo = [[NSString alloc] initWithFormat:@"%@", amount];
    
    return timeAgo;
}

@end
