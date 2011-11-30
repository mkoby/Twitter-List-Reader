//
//  TwitterClient.h
//  Twitter List Reader
//
//  Created by Michael Koby on 11/28/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface TwitterClient : NSObject

+ (NSDictionary *)getListsForAccount:(ACAccount *)account;

@end
