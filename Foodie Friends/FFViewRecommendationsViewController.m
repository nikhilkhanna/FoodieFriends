//
//  FFViewRecommendationsViewController.m
//  Foodie Friends
//
//  Created by Nikhil Khanna on 5/12/14.
//  Copyright (c) 2014 Nikhil Khanna. All rights reserved.
//

#import "FFViewRecommendationsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
@interface FFViewRecommendationsViewController ()

@end

@implementation FFViewRecommendationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //setting default value of 0 so as to not mess up table methods
        self.recommendations = [[NSMutableArray alloc] initWithCapacity:0];
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getFriends];
	// Do any additional setup after loading the view.
}

//gets all friends who use this app (they are the only ones who matter really)
-(void)getFriends
{
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        self.friendsOnApp = [result objectForKey:@"data"];
        NSLog(@"%@",self.friendsOnApp);
        [self queryDB];
    }];
}

-(void)queryDB
{
    PFQuery* query = [PFQuery queryWithClassName:@"Recommendation"];
    NSArray* IDArray = [self getFriendIDs];
    [query whereKey:@"fbid" containedIn:IDArray];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.recommendations = objects;
        //TODO update table / view / whatever here
        NSLog(@"%@",self.recommendations);
    }];
}

-(NSArray*) getFriendIDs
{
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for(id<FBGraphUser> friend in self.friendsOnApp)
    {
        [ids addObject:friend.id];
    }
    return ids;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
