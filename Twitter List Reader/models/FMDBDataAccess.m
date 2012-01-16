//
//  FMDBDataAccess.m
//  Twitter List Reader
//
//  Created by Michael Koby on 12/7/11.
//  Copyright (c) 2011 Michael Koby. All rights reserved.
//

#import "FMDBDataAccess.h"

@implementation FMDBDataAccess
@synthesize database;

- (FMDBDataAccess *)init {
    self = [super init];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.database = [FMDatabase databaseWithPath:appDelegate.databasePath];
    
    return self;
}

- (int)returnCountWithSqlString:(NSString *)sql {
    int output = 0;
    
    @try {
        if ([self.database open]) {
            int count = [self.database intForQuery:sql];
            
            if (count > 0)
                output = count;
        } else {
            NSLog(@"Error occured while opening the database");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"\n\n=== EXCEPTION CAUGHT ===\n\nName: %@\nDescription: %@\n\n", exception.name, exception.description);
    }
    @finally {
        [self.database close];
    }
    
    return output;
}

- (BOOL)updateDatabaseWithSqlString:(NSString *)sql {
    BOOL result = NO;
    
    @try {
        if ([self.database open]) {
            result = [self.database executeUpdate:sql];
            
            if (!result)
                NSLog(@"Update didn't complete for some reason");
            
        } else {
            NSLog(@"Error occured while opening the database");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"\n\n=== EXCEPTION CAUGHT ===\n\nName: %@\nDescription: %@\n\n", exception.name, exception.description);
    }
    @finally {
        [self.database close];
    }

    
    return result;
}

- (NSArray *)returnResultSetArrayWithSqlString:(NSString *)sql {
    NSArray *results = nil;
    
    @try {
        if ([self.database open]) {            
            FMResultSet *databaseResults = [self.database executeQuery:sql];
            
            if (databaseResults) {
                NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
                
                while ([databaseResults next]) {
                    NSMutableDictionary *rowDictionary = [[NSMutableDictionary alloc] init];
                    
                    for (int col = 0; col < databaseResults.columnCount; col++) {
                        NSString *columnName = [databaseResults columnNameForIndex:col];
                        NSObject *columnContents = [databaseResults objectForColumnIndex:col];
                        [rowDictionary setValue:columnContents forKey:columnName];
                    }
                    
                    [resultsArray addObject:[[NSDictionary alloc] initWithDictionary:rowDictionary]];
                }
                
                results = [[NSArray alloc] initWithArray:resultsArray];
            }
            
        } else {
            NSLog(@"Error occured while opening the database");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"\n\n=== EXCEPTION CAUGHT ===\n\nName: %@\nDescription: %@\n\n", exception.name, exception.description);
    }
    @finally {
        [self.database close];
    }
    
    return results;
}

- (BOOL)isList:(NSUInteger)listID activeForAccountIdentifier:(NSString *)accountIdentifier {
    BOOL result = NO;
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM active_lists WHERE account_identifier='%@' AND list_id=%d;", accountIdentifier, listID];
    int count = [self returnCountWithSqlString:sql];
    
    if (count > 0)
        result = YES;

    return result;
}

- (BOOL)addListID:(NSUInteger)listID forAccountIdentifier:(NSString *)accountIdentifier {
    BOOL result = NO;
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO active_lists (account_identifier, list_id) VALUES('%@', %d);", accountIdentifier, listID];
    result = [self updateDatabaseWithSqlString:sql];

    return result;
}

- (BOOL)removeListID:(NSUInteger)listID forAccountIdentifier:(NSString *)accountIdentifier {
    BOOL result = NO;
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM active_lists WHERE account_identifier='%@' AND list_id=%d;", accountIdentifier, listID];
    result = [self updateDatabaseWithSqlString:sql];
        
    return result;
}

- (NSArray *)getActiveLists {
    NSArray *output = nil;
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT account_identifier, list_id FROM active_lists;"];
    NSArray *results = [self returnResultSetArrayWithSqlString:sql];
    
    if (results) {
        NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *row in results) {
            NSString *accountIdentifier = (NSString *)[row valueForKeyPath:@"account_identifier"];
            NSNumber *listID = (NSNumber *)[row valueForKeyPath:@"list_id"];
            //NSLog(@"\nAccount Identifier: %@\nList ID: %d", accountIdentifier, [listID intValue]);
            
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            [tempDict setValue:accountIdentifier forKey:@"AccountIdentifier"];
            [tempDict setValue:listID forKey:@"ListID"];
            
            [resultsArray addObject:[[NSDictionary alloc] initWithDictionary:tempDict]];
        }
        
        output = [[NSArray alloc] initWithArray:resultsArray];
    }
        
    return output;
}

@end
