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
#import "Constants.h"
#import "AsyncImageView.h"

@interface FFViewRecommendationsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *recommendationsTable;

@end

@implementation FFViewRecommendationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //setting default value of 0 so as to not mess up table methods
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recommendationsTable.delegate = self;
    self.recommendationsTable.dataSource = self;
    [self updateView];
	// Do any additional setup after loading the view.
}

-(void)updateView
{
    //gets all friends who use this app (they are the only ones who matter really)
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray* friendsOnApp = [result objectForKey:@"data"];
        NSLog(@"%@",friendsOnApp);
        //queries DB to get all the relevent recommendations
        [self queryDB:friendsOnApp];
    }];
}

-(void)queryDB: (NSArray *)friendsOnApp
{
    PFQuery* query = [PFQuery queryWithClassName:kParseClassName];
    NSArray* IDArray = [self getFriendIDs: friendsOnApp];
    [query whereKey:kParseFBIDKey containedIn:IDArray];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.recommendations = objects;
        //TO DO, MAKE AN ARRAY OF RECOMMENDATIONS GROUPED BY RESTAURANT
        [self.recommendationsTable reloadData];
        NSLog(@"%@",self.recommendations);
    }];
}

-(NSArray*) getFriendIDs: (NSArray *)friendsOnApp
{
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for(id<FBGraphUser> friend in friendsOnApp)
    {
        [ids addObject:friend.id];
    }
    //ADDS MY OWN RECCOMENDATIONS TO THE TABLE FOR TESTING PURPOSES
    [ids addObject:[[NSUserDefaults standardUserDefaults] objectForKey:kUserIDKey]];//TEMP
    return ids;
}


//Table view data source methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recommendations count];
}

//generate a table cell at given index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    PFObject* recToShow = [self.recommendations objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@ recommends %@",
                           [recToShow objectForKey:kParseUserFirstNameKey],
                           [recToShow objectForKey:kParsePlaceNameKey]];
    cell.detailTextLabel.text = [recToShow objectForKey:kParsePlaceAddressKey];
    [cell.imageView setImage:[UIImage imageNamed:@"loading.png"]];

    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:
                                                     @"https://graph.facebook.com/%@/picture?",
                                                     [recToShow objectForKey:kParseFBIDKey]]];
    cell.imageView.imageURL = profilePictureURL;
    //[[AsyncImageLoader sharedLoader] loadImageWithURL:profilePictureURL target:profPic action:nil];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
