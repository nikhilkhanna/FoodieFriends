//
//  FFMainScreenViewController.m
//  Foodie Friends
//
//  Created by Nikhil Khanna on 5/9/14.
//  Copyright (c) 2014 Nikhil Khanna. All rights reserved.
//

#import "FFMainScreenViewController.h"
#import "Constants.h"
@interface FFMainScreenViewController ()

@end

@implementation FFMainScreenViewController

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
    NSString* userName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserNameKey];
    self.navigationItem.title = [NSString stringWithFormat:@"Welcome, %@", userName];
    
	// Do any additional setup after loading the view.
}

- (IBAction)unwindToMain:(UIStoryboardSegue *)unwindSegue
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
