//
//  AppDelegate.h
//  Community Playlist
//
//  Created by Akshat Keshan on 10/30/14.
//  Copyright (c) 2014 UCLA CS 130. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (Rdio *)rdioInstance;
+ (NSMutableArray *)trackKeysInstance;
+ (NSMutableArray *)trackNamesInstance;
+ (NSMutableArray *)tracksInfoInstance;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *trackKeys;
@property (nonatomic, retain) NSMutableArray *trackNames;
@property (nonatomic, retain) NSMutableArray *tracksInfo;
@property (readonly) Rdio *rdio;

@end

