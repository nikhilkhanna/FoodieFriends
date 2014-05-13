//
//  FFViewRecommendationsViewController.m
//  Foodie Friends
//
//  Created by Nikhil Khanna on 5/12/14.
//  Copyright (c) 2014 Nikhil Khanna. All rights reserved.
//

#import "FFViewRecommendationsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
@interface FFViewRecommendationsViewController ()

@end

@implementation FFViewRecommendationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getFriends];
	// Do any additional setup after loading the view.
}

-(void)getFriends
{
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        self.friendsOnApp = [result objectForKey:@"data"];
        NSLog(@"%@",self.friendsOnApp);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
