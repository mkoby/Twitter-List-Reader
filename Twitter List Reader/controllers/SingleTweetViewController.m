//
//  SingleTweetViewController.m
//  Twitter List Reader
//
//  Created by Michael Koby on 11/30/11.
//  Copyright (c) 2011 Teabrick. All rights reserved.
//

#import "SingleTweetViewController.h"

@implementation SingleTweetViewController
@synthesize selectedTweet, avatarImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"\nUsername: %@\nTweet: %@", self.selectedTweet.username, self.selectedTweet.tweet);
    
    UIImageView *avatarImageView = (UIImageView *)[self.view viewWithTag:1];
    avatarImageView.image = avatarImage;
    
    UILabel *userNameLabel = (UILabel *)[self.view viewWithTag:2];
    userNameLabel.text = selectedTweet.username;
    
    UILabel *timeSinceTweetLabel = (UILabel *)[self.view viewWithTag:4];
    NSString *timeSinceTweetText = [[NSString alloc] initWithFormat:@"%@ ago", [selectedTweet getDateDifferenceForTweetDateWithFullUnitsText:YES]];
    timeSinceTweetLabel.text = timeSinceTweetText;
    
    UITextView *tweetText = (UITextView *)[self.view viewWithTag:8];
    [tweetText setDataDetectorTypes:UIDataDetectorTypeLink];
    [tweetText setText:selectedTweet.tweet];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
