//
//  FMDBDataAccess.h
//  Twitter List Reader
//
//  Created by Michael Koby on 12/7/11.
//  Copyright (c) 2011 Michael Koby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"

@interface FMDBDataAccess : NSObject {
    FMDatabase *database;
}

@property (nonatomic, strong) FMDatabase *database;

- (BOOL)isList:(NSUInteger)listID activeForAccountIdentifier:(NSString *)accountIdentifier;
- (BOOL)addListID:(NSUInteger)listID forAccountIdentifier:(NSString *)accountIdentifier;
- (BOOL)removeListID:(NSUInteger)listID forAccountIdentifier:(NSString *)accountIdentifier;
- (NSArray *)getActiveLists;

- (int)returnCountWithSqlString:(NSString *)sql;
- (BOOL)updateDatabaseWithSqlString:(NSString *)sql;
- (NSArray *)returnResultSetArrayWithSqlString:(NSString *)sql;

@end
