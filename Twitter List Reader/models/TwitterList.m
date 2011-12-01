//
//  TwitterList.m
//  Twitter List Reader
//
//  Created by Michael Koby on 11/28/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import "TwitterList.h"

@implementation TwitterList
@synthesize name, description, listId;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSLog(@"%@", attributes);
    
    self.name = [attributes valueForKeyPath:@"name"];
    self.description = [attributes valueForKeyPath:@"description"];
//    self.listId = (NSUInteger *)[attributes valueForKeyPath:@"id"];
    
    return self;
}

@end
