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
#import "FFViewDetailRecommendationViewController.h"

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
    //setting properties of cell labels
    cell.textLabel.text = [NSString stringWithFormat: @"%@ recommends %@",
                           [recToShow objectForKey:kParseUserFirstNameKey],
                           [recToShow objectForKey:kParsePlaceNameKey]];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [recToShow objectForKey:kParsePlaceAddressKey];
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    
    //handling the cell image
    [cell.imageView setImage:[UIImage imageNamed:@"loading.png"]];
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:
                                                     @"https://graph.facebook.com/%@/picture?",
                                                     [recToShow objectForKey:kParseFBIDKey]]];
    //make it asynchrounously load the profile picture
    cell.imageView.imageURL = profilePictureURL;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.recommendationsTable deselectRowAtIndexPath:indexPath animated:FALSE];
    self.recToShow = [self.recommendations objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"viewDetails" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"viewDetails"])
    {
        FFViewDetailRecommendationViewController* detailViewController = segue.destinationViewController;
        detailViewController.recToShow = self.recToShow;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject* recToShow = [self.recommendations objectAtIndex:indexPath.row];
    NSString* content = [NSString stringWithFormat: @"%@ recommends %@",
    [recToShow objectForKey:kParseUserFirstNameKey],
    [recToShow objectForKey:kParsePlaceNameKey]];
    
    // Max size you will permit
    CGSize maxSize = CGSizeMake(200, 1000);
    CGSize size = [content sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17] constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    return size.height + 80;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
