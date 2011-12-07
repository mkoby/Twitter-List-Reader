//
//  TwitterList.m
//  Twitter List Reader
//
//  Created by Michael Koby on 11/28/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import "TwitterList.h"

@implementation TwitterList
@synthesize name, description, listId, fullName, mode;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    //NSLog(@"%@", attributes);
    
    self.name = [attributes valueForKeyPath:@"name"];
    self.description = [attributes valueForKeyPath:@"description"];
    self.fullName = [attributes valueForKeyPath:@"full_name"];
    self.mode = [attributes valueForKeyPath:@"mode"];
    self.listId = (NSUInteger)[[attributes valueForKeyPath:@"id"] intValue];
    
    return self;
}

+ (id)createNSDictionaryOfListsFromNSArray:(NSArray *)listsArray {
    NSMutableArray *privateLists = [[NSMutableArray alloc] init];
    NSMutableArray *publicLists = [[NSMutableArray alloc] init];
    
    for (TwitterList *list in listsArray) {
        if ([list.mode isEqualToString:@"private"])
            [privateLists addObject:list];
        if ([list.mode isEqualToString:@"public"])
            [publicLists addObject:list];
    }
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:privateLists,@"Private", publicLists,@"Public", nil];    
    
    return dictionary;
}

@end
