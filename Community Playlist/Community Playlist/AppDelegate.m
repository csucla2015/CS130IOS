//
//  AppDelegate.m
//  Community Playlist
//
//  Created by Akshat Keshan on 10/30/14.
//  Copyright (c) 2014 UCLA CS 130. All rights reserved.
//

#import "AppDelegate.h"
#import "RdioCredentials.h"
#import "TrackInfo.h"

static AppDelegate *launchedDelegate;

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (Rdio *)rdioInstance
{
    return launchedDelegate.rdio;
}

+ (NSMutableArray *)trackKeysInstance
{
    return launchedDelegate.trackKeys;
}

+ (NSMutableArray *)trackNamesInstance
{
    return launchedDelegate.trackNames;
}

+ (NSMutableArray *)tracksInfoInstance
{
    return launchedDelegate.tracksInfo;
}

@synthesize trackKeys;
@synthesize trackNames;
@synthesize tracksInfo;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    launchedDelegate = self;
    self.trackKeys = [[NSMutableArray alloc] init];
    self.trackNames = [[NSMutableArray alloc] init];
    self.tracksInfo = [[NSMutableArray alloc] init];
    
    
    // Let the device know we want to receive push notifications
    #ifdef __IPHONE_8_0
    //Right, that is the point
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                         |UIUserNotificationTypeSound
                                                                                         |UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    #else
    // Register to receive notifications
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    #endif
    
    _rdio = [[Rdio alloc] initWithConsumerKey:CONSUMER_KEY andSecret:CONSUMER_SECRET delegate:nil];
    [self.rdio preparePlayerWithDelegate:nil];
    
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    
    RDAPIRequestDelegate *trackDelegate = [RDAPIRequestDelegate delegateToTarget:self
                                                                    loadedAction:@selector(updateCurrentTrackRequest:didLoadData:)
                                                                    failedAction:@selector(updateCurrentTrackRequest:didFail:)];
    [[AppDelegate rdioInstance] callAPIMethod:@"search"
                               withParameters:@{@"query": message, @"types":@"track", @"extras":@"-*,key,name,artist,icon", @"count":@"1"}
                                     delegate:trackDelegate];
}

- (void)updateCurrentTrackRequest:(RDAPIRequest *)request didLoadData:(NSDictionary *)data
{
    TrackInfo *trackInfo = [[TrackInfo alloc] init];
    
    NSArray *metadata = [data objectForKey:@"results"];
    NSString *trackKey = [[metadata objectAtIndex:0] objectForKey:@"key"];
    NSLog(@"Track key found: %@", trackKey);
    trackInfo.trackKey = trackKey;
    NSLog(@"Track keys: %@", trackKeys);
    
    NSString *trackName = [[metadata objectAtIndex:0] objectForKey:@"name"];
    NSString *trackArtist = [[metadata objectAtIndex:0] objectForKey:@"artist"];
    NSMutableString *message = [trackName mutableCopy];
    [message appendString:@" by "];
    [message appendString:trackArtist];
    trackInfo.trackName = message;
    
    NSString *trackImageUrl = [[metadata objectAtIndex:0] objectForKey:@"icon"];
    trackInfo.trackImageUrl = trackImageUrl;
    
    NSString *cancelTitle = @"Cool";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Song Added"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancelTitle
                                              otherButtonTitles:nil];
    [alertView show];
    
    [tracksInfo addObject:trackInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTheTrackKeysArray" object:nil];

    
}

- (void)updateCurrentTrackRequest:(RDAPIRequest *)request didFail:(NSError *)error
{
    NSLog(@"error: %@", error);
}

- (void)application:(UIApplication *)application notifyUserThatSongWasAdded:(NSString *)message {

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}

@end
