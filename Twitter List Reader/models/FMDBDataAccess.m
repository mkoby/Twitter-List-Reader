//
//  FMDBDataAccess.m
//  Twitter List Reader
//
//  Created by Michael Koby on 12/7/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import "FMDBDataAccess.h"

@implementation FMDBDataAccess

+ (BOOL)isList:(NSUInteger)listID activeForAccountIdentifier:(NSString *)accountIdentifier {
    BOOL result = NO;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:appDelegate.databasePath];
    
    if ([db open]) {
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM active_lists WHERE account_identifier='%@' AND list_id=%d", accountIdentifier, listID];
        NSLog(@"%@", sql);
        int count = [db intForQuery:sql];
        
        if (count > 0)
            result = YES;
    } else {
        NSLog(@"Error occured while opening the database");
    }
    
    return result;
}

@end
