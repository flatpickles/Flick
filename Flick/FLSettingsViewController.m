//
//  FLSettingsViewController.m
//  Flick
//
//  Created by Matt Nichols on 1/23/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLSettingsViewController.h"

#define SETTINGS_TITLE @"Settings"

@interface FLSettingsViewController ()

@end

@implementation FLSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = SETTINGS_TITLE;
	self.view.backgroundColor = [UIColor whiteColor];

    // todo: actually use this view for something
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
