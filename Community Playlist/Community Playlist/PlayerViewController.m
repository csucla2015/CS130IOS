//
//  PlayerViewController.m
//  Community Playlist
//
//  Created by Akshat Keshan on 11/23/14.
//  Copyright (c) 2014 UCLA CS 130. All rights reserved.
//

#import "PlayerViewController.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>


#import "AppDelegate.h"
#import "TrackInfo.h"
#import "NSString+FontAwesome.h"

@interface PlayerViewController() {
    BOOL _playing;
    BOOL _paused;
    RDPlayer* _player;
    
    UIVisualEffectView *visualEffectView;
}

@end

@implementation PlayerViewController

- (RDPlayer *)player {
    if (_player == nil) {
        Rdio *sharedRdio = [AppDelegate rdioInstance];
        if (sharedRdio.player == nil) {
            [sharedRdio preparePlayerWithDelegate:self];
        }
        _player = sharedRdio.player;
    }
    return _player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.player addObserver:self forKeyPath:@"currentTrack" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
    
    // Blur Effect
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [visualEffectView setFrame:self.view.bounds];
    
    // Observe Local Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTrackKeysArray:) name:@"reloadTheTrackKeysArray" object:nil];
    
    // Set up table view
    [self.tableOfUpcomingTracks setDelegate:self];
    [self.tableOfUpcomingTracks setDataSource:self];
    [_tableOfUpcomingTracks setEditing:YES animated:YES];
    _tableOfUpcomingTracks.hidden = YES;
    [_tableOfUpcomingTracks setBackgroundColor:[UIColor clearColor]];
    [_tableOfUpcomingTracks setBackgroundView:nil];
    
    // Set up music player controls
    _prevButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [_prevButton setTitle:[NSString fontAwesomeIconStringForEnum:FABackward] forState:UIControlStateNormal];
    
    _nextButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [_nextButton setTitle:[NSString fontAwesomeIconStringForEnum:FAForward] forState:UIControlStateNormal];
    
    _playButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [_playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPlay] forState:UIControlStateNormal];
    
    [self playButtonPressed:nil];
    
    _currentArtistLabel.hidden = NO;
    _currentTrackLabel.hidden = NO;
    _prevButton.hidden = NO;
    _nextButton.hidden = NO;
    _playButton.hidden = NO;
    
    // Make toolbar transparent
    [self.toolbar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    [self.toolbar setShadowImage:[UIImage new]
              forToolbarPosition:UIToolbarPositionAny];
}

- (void)reloadTrackKeysArray:(NSNotification *)notification
{
    NSMutableArray *tracksInfo = [AppDelegate tracksInfoInstance];
    NSMutableArray *trackKeys = [[NSMutableArray alloc] init];
    for(TrackInfo *trackInfo in tracksInfo) {
        [trackKeys addObject:trackInfo.trackKey];
    }
    
    //NSArray *trackKeys = [AppDelegate trackKeysInstance];
    int index = self.player.currentTrackIndex;
    // Reorder the trackKeys array
    // Update index so it points at the currently playing track
    [self.player updateQueue:trackKeys withCurrentTrackIndex:index];
    
    
    [_tableOfUpcomingTracks reloadData];
    
    if(self.player.state == RDPlayerStateStopped) {
        [_nextButton setTitle:[NSString fontAwesomeIconStringForEnum:FARefresh] forState:UIControlStateNormal];
    } else {
        [_nextButton setTitle:[NSString fontAwesomeIconStringForEnum:FAForward] forState:UIControlStateNormal];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([self.player isEqual:object]) {  // should always be true
        if ([@"currentTrack" isEqualToString:keyPath]) {
            NSString *trackKey = [change valueForKey:NSKeyValueChangeNewKey];
            
            if (trackKey && [trackKey isKindOfClass:[NSString class]]) {
                RDAPIRequestDelegate *trackDelegate = [RDAPIRequestDelegate delegateToTarget:self
                                                                                loadedAction:@selector(updateCurrentTrackRequest:didLoadData:)
                                                                                failedAction:@selector(updateCurrentTrackRequest:didFail:)];
                [[AppDelegate rdioInstance] callAPIMethod:@"get"
                                                withParameters:@{@"keys": trackKey, @"extras":@"-*,name,artist,icon400,icon"}
                                                      delegate:trackDelegate];
            } else {
                [_currentTrackLabel setText:@""];
                [_currentArtistLabel setText:@""];
            }
        }
    }
}

- (void)updateCurrentTrackRequest:(RDAPIRequest *)request didLoadData:(NSDictionary *)data
{
    NSString *trackKey = [request.parameters objectForKey:@"keys"];
    NSDictionary *metadata = [data objectForKey:trackKey];
    [_currentTrackLabel setText:[metadata objectForKey:@"name"]];
    [_currentArtistLabel setText:[metadata objectForKey:@"artist"]];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[metadata objectForKey:@"icon400"]]];
    _trackImage.image = [UIImage imageWithData:imageData];
    NSData *imageIconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[metadata objectForKey:@"icon"]]];
    _trackIcon.image = [UIImage imageWithData:imageIconData];
    
    //Blur Effect

    //visualEffectView.frame = _trackImage.bounds;
    [_trackImage addSubview:visualEffectView];
    
    //[self.view insertSubview:_trackImage atIndex:0];
    
    int index = self.player.currentTrackIndex;
    if((index + 1) == [[AppDelegate tracksInfoInstance] count] || [[AppDelegate tracksInfoInstance] count] == 1) {
        [_nextButton setTitle:[NSString fontAwesomeIconStringForEnum:FARefresh] forState:UIControlStateNormal];
    } else {
        [_nextButton setTitle:[NSString fontAwesomeIconStringForEnum:FAForward] forState:UIControlStateNormal];
    }
    
    if(index == 0) {
        _prevButton.enabled = NO;
        _prevButton.hidden = YES;
    } else {
        _prevButton.enabled = YES;
        _prevButton.hidden = NO;
    }
    
    [_tableOfUpcomingTracks reloadData];
}

- (void)updateCurrentTrackRequest:(RDAPIRequest *)request didFail:(NSError *)error
{
    NSLog(@"error: %@", error);
}


#pragma mark - UI event and state handling
- (IBAction)playButtonPressed:(id)sender {
    if (!_playing) {
        NSMutableArray *tracksInfo = [AppDelegate tracksInfoInstance];
        NSMutableArray *trackKeys = [[NSMutableArray alloc] init];
        for(TrackInfo *trackInfo in tracksInfo) {
            [trackKeys addObject:trackInfo.trackKey];
        }
        [self.player playSources:trackKeys];
        
        [_playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPause] forState:UIControlStateNormal];
        _playing = true;
    } else {
        [self.player togglePause];
        if([_playButton.titleLabel.text isEqual:[NSString fontAwesomeIconStringForEnum:FAPlay]]) {
            [_playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPause] forState:UIControlStateNormal];
        } else {
            [_playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPlay] forState:UIControlStateNormal];
        }
        //_playing = false;
        //[_playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (IBAction)prevButtonPressed:(id)sender {
    [self.player previous];
    [_playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPause] forState:UIControlStateNormal];
}

- (IBAction)nextButtonPressed:(id)sender {
    if([_nextButton.titleLabel.text isEqual:[NSString fontAwesomeIconStringForEnum:FARefresh]]) {
        NSMutableArray *tracksInfo = [AppDelegate tracksInfoInstance];
        NSMutableArray *trackKeys = [[NSMutableArray alloc] init];
        for(TrackInfo *trackInfo in tracksInfo) {
            [trackKeys addObject:trackInfo.trackKey];
        }
        [self.player playSources:trackKeys];
    }
    
    [self.player next];
    [_playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPause] forState:UIControlStateNormal];
}

- (IBAction)sharePressed:(id)sender {
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    [sharingItems addObject:@"Text (424) 322-1755 to add songs to my playlist!"];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
    
    if ([activityController respondsToSelector:@selector(popoverPresentationController)]) {
        // iOS 8+
        UIPopoverPresentationController *presentationController = [activityController popoverPresentationController];
        presentationController.sourceView = sender; // if button or change to self.view.
    }
}

#pragma mark - RDPlayerDelegate
- (BOOL)rdioIsPlayingElsewhere
{
    // let the Rdio framework tell the user.
    return NO;
}

- (void)rdioPlayerChangedFromState:(RDPlayerState)fromState toState:(RDPlayerState)state
{
    _playing = (state != RDPlayerStateInitializing && state != RDPlayerStateStopped);
    _paused = (state == RDPlayerStatePaused);
    if (_paused || !_playing) {
        [_playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPlay] forState:UIControlStateNormal];
//        [self stopObservers];
    } else {
        [_playButton setTitle:[NSString fontAwesomeIconStringForEnum:FAPause] forState:UIControlStateNormal];
//        [self startObservers];
    }
}

- (BOOL)rdioPlayerFailedDuringTrack:(NSString *)trackKey withError:(NSError *)error
{
    NSLog(@"Rdio failed to play track %@\n%@", trackKey, error);
    return NO;
}

- (void)rdioPlayerQueueDidChange
{
    NSLog(@"Rdio queue changed to %@", [self.player trackKeys]);
}

//UITableView Properties
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[AppDelegate tracksInfoInstance] count] - 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    NSMutableArray *tracksInfo = [AppDelegate tracksInfoInstance];
    NSMutableArray *trackNames = [[NSMutableArray alloc] init];
    NSMutableArray *trackImageUrls = [[NSMutableArray alloc] init];
    for(TrackInfo *trackInfo in tracksInfo) {
        [trackNames addObject:trackInfo.trackName];
        [trackImageUrls addObject:trackInfo.trackImageUrl];
    }
    
    NSInteger playerIndexOffset = self.player.currentTrackIndex + 1;
    NSInteger indexPathRowWithOffset = indexPath.row + playerIndexOffset;
    if(indexPathRowWithOffset < [tracksInfo count]) {
        NSString *trackName = [trackNames objectAtIndex:indexPathRowWithOffset];
        cell.textLabel.text = trackName;
        
        NSString *trackImageUrl = [trackImageUrls objectAtIndex:indexPathRowWithOffset];
        NSData *imageIconData = [NSData dataWithContentsOfURL:[NSURL URLWithString:trackImageUrl]];
        cell.imageView.image = [UIImage imageWithData:imageIconData];
        
        _tableOfUpcomingTracks.hidden = NO;
    } else {
        cell.textLabel.text = @"";
        cell.imageView.image = nil;
        cell.hidden = YES;
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

#pragma mark Row reordering
// Determine whether a given row is eligible for reordering or not.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
// Process the row move. This means updating the data model to correct the item indices.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSInteger playerIndexOffset = self.player.currentTrackIndex + 1;
    NSInteger fromIndexPathRowWithOffset = fromIndexPath.row + playerIndexOffset;
    NSInteger toIndexPathRowWithOffset = toIndexPath.row + playerIndexOffset;

    NSString *item = [[AppDelegate tracksInfoInstance] objectAtIndex:fromIndexPathRowWithOffset];
    [[AppDelegate tracksInfoInstance] removeObject:item];
    [[AppDelegate tracksInfoInstance] insertObject:item atIndex:toIndexPathRowWithOffset];
    [self reloadTrackKeysArray:nil];
    
}

#pragma mark Row deletion
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSMutableArray *tracksInfo = [AppDelegate tracksInfoInstance];
//    NSInteger playerIndexOffset = self.player.currentTrackIndex + 1;
//    NSInteger indexPathRowWithOffset = indexPath.row + playerIndexOffset;
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [tracksInfo removeObjectAtIndex:indexPathRowWithOffset];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        //[self reloadTrackKeysArray:nil];
//    } else {
//        NSLog(@"Unhandled editing style! %d", editingStyle);
//    }
//}

//Methods to disable the Delete Button in edit mode for the UITableView
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
        return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


@end
