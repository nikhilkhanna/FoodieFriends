//
//  FFViewRecommendationsViewController.h
//  Foodie Friends
//
//  Created by Nikhil Khanna on 5/12/14.
//  Copyright (c) 2014 Nikhil Khanna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface FFViewRecommendationsViewController : UIViewController

@property NSArray* recommendations;
@property PFObject* recToShow;

@end
