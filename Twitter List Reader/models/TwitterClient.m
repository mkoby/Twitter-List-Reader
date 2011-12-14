//
//  TwitterClient.m
//  Twitter List Reader
//
//  Created by Michael Koby on 11/28/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import "TwitterClient.h"
#import "AppDelegate.h"
#import "TweetItem.h"

@implementation TwitterClient

+ (NSDictionary *)getListsForAccount:(ACAccount *)account {
    NSString *listsURL = @"http://api.twitter.com/1/lists/all.json";
    TWRequest *listsRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:listsURL] 
                                                  parameters:nil 
                                               requestMethod:TWRequestMethodGET];
    listsRequest.account = account;
    __block NSDictionary *returnedLists = nil;    
    [listsRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) 
        {
            // The response from Twitter is in JSON format
            // Move the response into a dictionary and print
            NSError *error;        
            returnedLists = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            NSLog(@"Twitter response: %@", returnedLists);                           
        }
        else
            NSLog(@"Twitter error, HTTP response: %i", [urlResponse statusCode]);
    }];
    
    return returnedLists;
}

+ (NSArray *)getTimelineForListWithId:(NSUInteger)listId forAccountWithIdentifier:(NSString *)accountIdentifier {
    NSArray *output = nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ACAccountStore *accounts = appDelegate.accountStore;
    ACAccount *account = [accounts accountWithIdentifier:accountIdentifier];
    NSString *listsURL = @"https://api.twitter.com/1/lists/statuses.json";
    NSMutableDictionary *requestParameters = [[NSMutableDictionary alloc] init];
    NSString *listIdAsString = [[NSString alloc] initWithFormat:@"%d", listId];
    [requestParameters setObject:listIdAsString forKey:@"list_id"];
    [requestParameters setObject:@"1" forKey:@"include_rts"];
    TWRequest *listsRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:listsURL] 
                                                  parameters:requestParameters 
                                               requestMethod:TWRequestMethodGET];
    listsRequest.account = account;
    
    __block NSDictionary *returnedTweets = nil;
    [listsRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 200) 
        {
            // The response from Twitter is in JSON format
            // Move the response into a dictionary and print
            NSError *error;        
            returnedTweets = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            //NSLog(@"Twitter response: %@", returnedTweets);
        }
        else
            NSLog(@"Twitter error, HTTP response: %i", [urlResponse statusCode]);
    }];
    
    if (returnedTweets == nil)
        NSLog(@"No returned tweets, this is probably wrong");
    
    if (returnedTweets != nil) {
        if (returnedTweets != nil) {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            
            for (NSDictionary *tweet in returnedTweets) {
                //NSLog(@"%@", tweet);
                TweetItem *item = [[TweetItem alloc] initWithAttributes:tweet];
                [items addObject:item];
            }
            
            output = [[NSArray alloc] initWithArray:items];
        }
    }
    
    return output;
}

@end
