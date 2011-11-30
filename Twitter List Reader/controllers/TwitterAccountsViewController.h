//
//  TwitterAccountsViewController.h
//  Twitter List Reader
//
//  Created by Michael Koby on 11/30/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

#define kAccountName 1

@interface TwitterAccountsViewController : UITableViewController {
    NSArray *twitterAccounts;
    UITableView *accountsTable;
}

@property (nonatomic, strong) NSArray *twitterAccounts;
@property (nonatomic, strong) IBOutlet UITableView *accountsTable;

- (void)getTwitterAccounts;

@end
