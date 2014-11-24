//
//  PlayerViewController.h
//  Community Playlist
//
//  Created by Akshat Keshan on 11/23/14.
//  Copyright (c) 2014 UCLA CS 130. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rdio/Rdio.h"

@interface PlayerViewController : UIViewController<RdioDelegate,RDPlayerDelegate>

@property (readonly, nonatomic, weak) RDPlayer *player;

@property (strong, nonatomic) IBOutlet UIButton *prevButton;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) IBOutlet UILabel *currentTrackLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentArtistLabel;


- (IBAction)playButtonPressed:(id)sender;
- (IBAction)prevButtonPressed:(id)sender;
- (IBAction)nextButtonPressed:(id)sender;
@end
