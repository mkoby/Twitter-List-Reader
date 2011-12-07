//
//  FMDBDataAccess.m
//  Twitter List Reader
//
//  Created by Michael Koby on 12/7/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
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

- (BOOL)isList:(NSUInteger)listID activeForAccountIdentifier:(NSString *)accountIdentifier {
    BOOL result = NO;
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM active_lists WHERE account_identifier='%@' AND list_id=%d", accountIdentifier, listID];
    int count = [self returnCountWithSqlString:sql];
    
    if (count > 0)
        result = YES;

    return result;
}

- (BOOL)addListID:(NSUInteger)listID forAccountIdentifier:(NSString *)accountIdentifier {
    BOOL result = NO;
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO active_lists (account_identifier, list_id) VALUES('%@', %d)", accountIdentifier, listID];
    result = [self updateDatabaseWithSqlString:sql];

    return result;
}

- (BOOL)removeListID:(NSUInteger)listID forAccountIdentifier:(NSString *)accountIdentifier {
    BOOL result = NO;
    NSString *sql = [[NSString alloc] initWithFormat:@"DELETE FROM active_lists WHERE account_identifier='%@' AND list_id=%d", accountIdentifier, listID];
    result = [self updateDatabaseWithSqlString:sql];
        
    return result;
}

@end
