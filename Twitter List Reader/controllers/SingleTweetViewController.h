//
//  SingleTweetViewController.h
//  Twitter List Reader
//
//  Created by Michael Koby on 11/30/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetItem.h"

@interface SingleTweetViewController : UIViewController {
    TweetItem *selectedTweet;
    UIImage *avatarImage;
}

@property (nonatomic, strong) TweetItem *selectedTweet;
@property (nonatomic, strong) UIImage *avatarImage;

@end
