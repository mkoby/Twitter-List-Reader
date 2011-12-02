//
//  AccountListsViewController.h
//  Twitter List Reader
//
//  Created by Michael Koby on 11/30/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface AccountListsViewController : UITableViewController {
    UITableView *listsTable;
    ACAccount *account;
    NSArray *listsData;
    NSDictionary *accountLists;
    NSArray *sortedKeys;
}

@property (nonatomic, strong) IBOutlet UITableView *listsTable;
@property (nonatomic, strong) ACAccount *account;
@property (nonatomic, strong) NSDictionary *accountLists;
@property (nonatomic, strong) NSArray *listsData;
@property (nonatomic, strong) NSArray *sortedKeys;

- (void)getListsForAccount:(ACAccount *)twitterAccount;

@end
