//
//  FFDetailRecommendViewController.m
//  Foodie Friends
//
//  Created by Nikhil Khanna on 5/10/14.
//  Copyright (c) 2014 Nikhil Khanna. All rights reserved.
//

#import "FFDetailRecommendViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>

@interface FFDetailRecommendViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *commentBox;

@end

@implementation FFDetailRecommendViewController

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
    self.nameLabel.text = [self.place objectForKey:@"name"];
    self.addressLabel.text = [self.place objectForKey:@"vicinity"];
    self.commentBox.delegate = self;
    //setting up touch off screen closing key
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [self retrievePhoto];
    // Do any additional setup after loading the view.
}

- (void)retrievePhoto
{
    NSArray* photoArray = [self.place objectForKey:@"photos"];
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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"submitSegue"])
    {
        [self saveRec];
    }
}

//saves a reccomendation
-(void) saveRec
{
    PFObject *recommendationObject = [PFObject objectWithClassName:@"Recommendation"];
    recommendationObject[@"reference"] = [self.place objectForKey:@"reference"];
    recommendationObject[@"comment"] = self.commentBox.text;
    recommendationObject[@"fbid"] = [[NSUserDefaults standardUserDefaults] objectForKey:kUserIDKey];
    [recommendationObject saveInBackground];
}

//text field delgate methods//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard];
    return YES;
}

-(void)dismissKeyboard
{
    [self.commentBox resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
