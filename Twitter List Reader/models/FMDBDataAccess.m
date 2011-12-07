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
        int count = [db intForQuery:sql];
        
        if (count > 0)
            result = YES;
    } else {
        NSLog(@"Error occured while opening the database");
    }
    
    [db close];
    
    return result;
}

+ (BOOL)addListID:(NSUInteger)listID forAccountIdentifier:(NSString *)accountIdentifier {
    BOOL result = NO;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:appDelegate.databasePath];
    
    if ([db open]) {
        NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO active_lists (account_identifier, list_id) VALUES('%@', %d)", accountIdentifier, listID];
        [db executeUpdate:sql];
    } else {
        NSLog(@"Error occured while opening the database");
    }
    
    [db close];
    
    return result;
}

+ (BOOL)removeListID:(NSUInteger)listID forAccountIdentifier:(NSString *)accountIdentifier {
    BOOL result = NO;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FMDatabase *db = [FMDatabase databaseWithPath:appDelegate.databasePath];
    
    if ([db open]) {
        NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM active_lists WHERE account_identifier='%@' AND list_id=%d", accountIdentifier, listID];
        [db executeUpdate:sql];
    } else {
        NSLog(@"Error occured while opening the database");
    }
    
    [db close];

    return result;
}

@end
