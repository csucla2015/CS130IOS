//
//  ViewController.m
//  Community Playlist
//
//  Created by Akshat Keshan on 10/30/14.
//  Copyright (c) 2014 UCLA CS 130. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)creatorButton:(UIButton *)sender {
}

- (IBAction)contributorButton:(UIButton *)sender {
}
@end
