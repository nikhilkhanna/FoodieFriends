//
//  FFViewDetailRecommendationViewController.m
//  Foodie Friends
//
//  Created by Nikhil Khanna on 5/15/14.
//  Copyright (c) 2014 Nikhil Khanna. All rights reserved.
//

#import "FFViewDetailRecommendationViewController.h"
#import "Constants.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface FFViewDetailRecommendationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UITextView *siteLink;

@end

@implementation FFViewDetailRecommendationViewController

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
    self.title = [[self.recToShow objectForKey:kParsePlaceNameKey] capitalizedString];
    self.titleLabel.text = [[self.recToShow objectForKey:kParsePlaceNameKey] capitalizedString];
    [self makeCommentLabel];
    [self makeDirectionsButton];
    [self queryGooglePlacesAndUpdate];
	// Do any additional setup after loading the view.
}

- (void)makeDirectionsButton
{
    [self.directionsButton setTitle:[NSString stringWithFormat:@"Tap here for directions to: %@",
                                     [self.recToShow objectForKey:kParsePlaceAddressKey]]
                           forState:UIControlStateNormal];
    self.directionsButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.directionsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)makeCommentLabel
{
    if(![[self.commentLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]isEqualToString:@""])
    {
        self.commentLabel.text = [NSString stringWithFormat:@"%@ says: %@",
                                  [self.recToShow objectForKey:kParseUserFirstNameKey],
                                  [self.recToShow objectForKey:kParseCommentKey]];
    }
    else
    {
        self.commentLabel.text = @"";
    }
}

- (void)queryGooglePlacesAndUpdate
{
    NSString* url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@", [self.recToShow objectForKey:kParseReferenceKey], kGoogleAPIKey];
    NSURL* requestURL = [NSURL URLWithString:url];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:requestURL];
        if (data == nil) {
            NSLog(@"NULL DATA!!!!");
            return;
        }
        [self performSelectorOnMainThread: @selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData
{
    NSError* error;
    NSDictionary *place = [[NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error] objectForKey:@"result"];
    self.priceLabel.text = [self priceText:place];
    self.siteLink.text = [self websiteText:place];
    [self retrievePhoto:place];
    
}

- (NSString*)priceText: (NSDictionary*) place
{
    NSNumber* n = [place objectForKey:@"price_level"];
    if(n == nil)
        return @"";
    NSMutableString* priceString = [NSMutableString stringWithString:@"price: "];
    for(int i = 0; i < [n intValue]; i++)
    {
        [priceString appendString:@"$"];
    }
    return priceString;
}

- (NSString*)websiteText: (NSDictionary*) place
{
    NSString* website = [place objectForKey:@"website"];
    if (website == nil) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@'s website: %@",[self.recToShow objectForKey:kParsePlaceNameKey], website];
}

- (void)retrievePhoto: (NSDictionary *) place
{
    NSArray* photoArray = [place objectForKey:@"photos"];
    if(photoArray == nil)
    {
        return;
    }
    NSDictionary* photoDict = [photoArray firstObject];
    NSString* url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?photoreference=%@&sensor=true&maxheight=%@&maxwidth=%@&key=%@",
                     [photoDict objectForKey:@"photo_reference"],
                     [photoDict objectForKey:@"height"],
                     [photoDict objectForKey:@"width"],
                     kGoogleAPIKey];
    NSURL* imageUrl = [NSURL URLWithString:url];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            self.imageView.image = [UIImage imageWithData:imageData];
        });
    });
}

- (IBAction)getDirections:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
