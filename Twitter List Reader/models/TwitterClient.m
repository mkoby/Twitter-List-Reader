//
//  TwitterClient.m
//  Twitter List Reader
//
//  Created by Michael Koby on 11/28/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import "TwitterClient.h"

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

@end
