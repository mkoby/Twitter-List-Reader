//
//  TwitterList.h
//  Twitter List Reader
//
//  Created by Michael Koby on 11/28/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterList : NSObject {
    NSUInteger listId;
    NSString *name, *fullName, *description, *mode;
}

@property (nonatomic) NSUInteger listId;
@property (nonatomic, strong) NSString *name, *fullName, *description, *mode;

- (id)initWithAttributes:(NSDictionary *)attributes;
+ (id)createNSDictionaryOfListsFromNSArray:(NSArray *)listsArray;

@end
