//
//  ViewController.h
//  Community Playlist
//
//  Created by Akshat Keshan on 10/30/14.
//  Copyright (c) 2014 UCLA CS 130. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *titleOutlet;

- (IBAction)creatorButton:(UIButton *)sender;
- (IBAction)contributorButton:(UIButton *)sender;

@end

