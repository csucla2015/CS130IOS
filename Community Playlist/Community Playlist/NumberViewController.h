//
//  NumberViewController.h
//  Community Playlist
//
//  Created by Akshat Keshan on 12/4/14.
//  Copyright (c) 2014 UCLA CS 130. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumberViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *playNowBarButtonItemOutlet;

- (IBAction)sharePressed:(id)sender;
@end
