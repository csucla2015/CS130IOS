//
//  NumberViewController.m
//  Community Playlist
//
//  Created by Akshat Keshan on 12/4/14.
//  Copyright (c) 2014 UCLA CS 130. All rights reserved.
//

#import "NumberViewController.h"
#import "AppDelegate.h"

@interface NumberViewController ()

@end

@implementation NumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Observe Local Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableNavigationBarButtonItem:) name:@"reloadTheTrackKeysArray" object:nil];
    
    if([[AppDelegate tracksInfoInstance] count] > 0) {
        _playNowBarButtonItemOutlet.enabled = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = NO;
}

- (void)enableNavigationBarButtonItem:(NSNotification *)notification
{
    _playNowBarButtonItemOutlet.enabled = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
@end
