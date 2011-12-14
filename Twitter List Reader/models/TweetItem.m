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
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setTimeStyle:NSDateFormatterFullStyle];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"EEE, d LLL yyyy HH:mm:ss Z"];
    
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

@end
