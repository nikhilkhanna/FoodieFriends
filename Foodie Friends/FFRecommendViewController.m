//
//  FFRecommendViewController.m
//  Foodie Friends
//
//  Created by Nikhil Khanna on 5/9/14.
//  Copyright (c) 2014 Nikhil Khanna. All rights reserved.
//

#import "FFRecommendViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
 #import <QuartzCore/QuartzCore.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface FFRecommendViewController () <CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource>

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *initialText;
@property (weak, nonatomic) IBOutlet UILabel *noResultsText;
@property NSArray *places;

@end

@implementation FFRecommendViewController

//Class Constants
static const double UPDATE_DISTANCE = 1000;
static const double RADIUS = 50000;

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
    [self showInitialTable];
    [self.searchBar setDelegate:self];
    [self.tableView setDataSource:self];
    [self createLocationManager];
}

-(void)createLocationManager
{
    [self setLocationManager:[[CLLocationManager alloc] init]];
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [_locationManager setDistanceFilter: UPDATE_DISTANCE];
    [_locationManager startUpdatingLocation];
}

//called when location is updated (obviously)
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    NSLog(@"%f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    [self queryGooglePlaces:@""];
}

//upon updating location find close locations
- (void) queryGooglePlaces:(NSString*) nameFragment
{
    //if there is no search entered
    if([[nameFragment stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] length] == 0)
    {
        [self showInitialTable];
        return;
    }
    NSString* escapedNameFragment = [self escapeName:nameFragment];
    //build url to send to google using data
    //TODO make types include restaurants food cafe, etc.
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=50000&types=restaurant&sensor=true&name=%@&key=%@", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude,escapedNameFragment,kGoogleAPIKey];
    
    NSURL *googleRequestUrl = [NSURL URLWithString:url];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:googleRequestUrl];
        if (data == nil) {
            NSLog(@"NULL DATA!!!!");
            [self showNoResultsTable];
            return;
        }
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

-(NSString*) escapeName: (NSString*) stringToEscape
{
    return [stringToEscape stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
}

//parsing though the fetched JSON data
- (void)fetchedData:(NSData *)responseData
{
    NSError* error;
    NSDictionary *jsonData = [NSJSONSerialization
                             JSONObjectWithData:responseData
                             options:kNilOptions
                             error:&error];
    self.places = [jsonData objectForKey:@"results"];
    for (int i = 0; i<[self.places count]; i++) {
        NSDictionary* place = [self.places objectAtIndex:i];
        NSLog(@"%d: %@", i, [place objectForKey:@"name"] );
    }
    if([self.places count]==0)
    {
        [self showNoResultsTable];
        return;
    }
    //reloading the table views
    self.tableView.hidden = FALSE;
    self.noResultsText.hidden = TRUE;
    self.initialText.hidden = TRUE;
    [self.tableView reloadData];
}


-(void)showInitialTable
{
    self.tableView.hidden = TRUE;
    self.initialText.hidden = FALSE;
    self.noResultsText.hidden = TRUE;
}

-(void)showNoResultsTable
{
    self.tableView.hidden = TRUE;
    self.initialText.hidden = TRUE;
    self.noResultsText.hidden = FALSE;
}

//table view source methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

//makes a cell for the table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    //occasionally count gets messed up and index out of bounds exceptions are hit
    @try
    {
        NSDictionary* currentPlace = [self.places objectAtIndex:indexPath.row];
        cell.textLabel.text = [currentPlace objectForKey:@"name"];
        cell.detailTextLabel.text = [currentPlace objectForKey:@"vicinity"];
    }
    @catch (NSException *e) {

    }
    return cell;
}

//Search bar delegate method used to reset data when text is entered
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self queryGooglePlaces: searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
