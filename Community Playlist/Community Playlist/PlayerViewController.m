//
//  PlayerViewController.m
//  Community Playlist
//
//  Created by Akshat Keshan on 11/23/14.
//  Copyright (c) 2014 UCLA CS 130. All rights reserved.
//

#import "PlayerViewController.h"
#import <CoreMedia/CoreMedia.h>

#import "AppDelegate.h"

@interface PlayerViewController() {
//    UIButton *_playButton;
//    UIButton *_loginButton;
//    BOOL _loggedIn;
    BOOL _playing;
    BOOL _paused;
//    BOOL _seeking;
    RDPlayer* _player;
    
//    UISlider *_leftLevelMonitor;
//    UISlider *_rightLevelMonitor;
//    
//    UISlider *_positionSlider;
//    UILabel *_positionLabel;
    UILabel *_durationLabel;
//
//    UILabel *_currentTrackLabel;
//    UILabel *_currentArtistLabel;
//    
//    id _timeObserver;
//    id _levelObserver;
    double _currentTrackDuration;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.player addObserver:self forKeyPath:@"currentTrack" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
//    [self startObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.player removeObserver:self forKeyPath:@"currentTrack"];
    [self.player removeObserver:self forKeyPath:@"duration"];
//    [self stopObservers];
    
    [super viewDidDisappear:animated];
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
                                                withParameters:@{@"keys": trackKey, @"extras":@"-*,name,artist"}
                                                      delegate:trackDelegate];
            } else {
                [_currentTrackLabel setText:@""];
                [_currentArtistLabel setText:@""];
            }
        } else if ([@"duration" isEqualToString:keyPath]) {
            NSNumber *duration = [change valueForKey:NSKeyValueChangeNewKey];
            _currentTrackDuration = [duration doubleValue];
//            _durationLabel.text = [self formattedTimeForInterval:_currentTrackDuration];
        }
    }
}

- (void)updateCurrentTrackRequest:(RDAPIRequest *)request didLoadData:(NSDictionary *)data
{
    NSString *trackKey = [request.parameters objectForKey:@"keys"];
    NSDictionary *metadata = [data objectForKey:trackKey];
    [_currentTrackLabel setText:[metadata objectForKey:@"name"]];
    [_currentArtistLabel setText:[metadata objectForKey:@"artist"]];
}

- (void)updateCurrentTrackRequest:(RDAPIRequest *)request didFail:(NSError *)error
{
    NSLog(@"error: %@", error);
}


#pragma mark - UI event and state handling
- (IBAction)playButtonPressed:(id)sender {
    if (!_playing) {
        NSArray* keys = [@"t15907959,t1992210,t7418766,t8816323" componentsSeparatedByString:@","];
        [self.player playSources:keys];
    } else {
        [self.player togglePause];
    }

}

- (IBAction)prevButtonPressed:(id)sender {
    [self.player previous];
}

- (IBAction)nextButtonPressed:(id)sender {
    [self.player next];
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
        [_playButton setTitle:@"Play" forState:UIControlStateNormal];
//        [self stopObservers];
    } else {
        [_playButton setTitle:@"Pause" forState:UIControlStateNormal];
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

@end
