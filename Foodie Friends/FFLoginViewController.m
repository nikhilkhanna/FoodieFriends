//
//  FFLoginViewController.m
//  Foodie Friends
//
//  Created by Nikhil Khanna on 5/9/14.
//  Copyright (c) 2014 Nikhil Khanna. All rights reserved.
//

#import "FFLoginViewController.h"
#import "Constants.h"
@interface FFLoginViewController ()
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@end

@implementation FFLoginViewController

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
    NSLog(@"just started up!");
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    self.loginView.delegate = self;
	// Do any additional setup after loading the view.
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    [[NSUserDefaults standardUserDefaults] setObject:user.name forKey:kUserNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:user.id forKey:kUserIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:user.first_name forKey:kUserFirstNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
