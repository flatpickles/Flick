//
//  FLConnectDropboxViewController.m
//  Flick
//
//  Created by Matt Nichols on 2/14/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLConnectDropboxViewController.h"
#import "FLDropboxHelper.h"

#define CONNECT_BUTTON_LABEL @"Let’s get started"
#define CONNECT_CAPTION @"To commence the noble effort of pasting to the cloud, we’ll need to create a folder in your Dropbox."
#define CONNECT_TITLE @"Welcome to Flick!"
#define EDGE_INSETS 11.0f
#define ERROR_BUTTON_LABEL @"Try again"
#define ERROR_CAPTION @"Looks like something went wrong. We’ll still need to connect with your Dropbox to get started, so let’s give it another shot."
#define ERROR_TITLE @"Whoops"

@interface FLConnectDropboxViewController ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *description;
@property (nonatomic) UIButton *connect;
@property (nonatomic) BOOL shouldDismiss;

@end

@implementation FLConnectDropboxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Connect to Dropbox";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:24.0f];
    self.titleLabel.text = CONNECT_TITLE;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];

    self.description = [[UILabel alloc] init];
    self.description.text = CONNECT_CAPTION;
    self.description.textAlignment = NSTextAlignmentCenter;
    self.description.lineBreakMode = NSLineBreakByWordWrapping;
    self.description.numberOfLines = 0;
    [self.view addSubview:self.description];

    self.connect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.connect.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [self.connect setTitle:CONNECT_BUTTON_LABEL forState:UIControlStateNormal];
    [self.connect addTarget:self action:@selector(_beginDropbox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.connect];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.shouldDismiss) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLayoutSubviews
{
    // this is hella gross and should have its own view, but YOLO

    [super viewDidLayoutSubviews];
    CGFloat topOffset = EDGE_INSETS + [[UIApplication sharedApplication] statusBarFrame].size.height;

    self.titleLabel.frame = CGRectInset(CGRectMake(0, topOffset, self.view.bounds.size.width, self.view.bounds.size.height - topOffset), EDGE_INSETS, EDGE_INSETS);
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(self.view.bounds.size.width/2, self.titleLabel.center.y);

    self.description.frame = CGRectInset(CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.view.bounds.size.width, self.view.bounds.size.height - topOffset), EDGE_INSETS, EDGE_INSETS);
    [self.description sizeToFit];
    self.description.center = CGPointMake(self.view.bounds.size.width/2, self.description.center.y);

    self.connect.frame = CGRectMake(0, CGRectGetMaxY(self.description.frame) + EDGE_INSETS*2, 200, 40);
    [self.connect sizeToFit];
    self.connect.center = CGPointMake(self.view.bounds.size.width/2, self.connect.center.y);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_beginDropbox
{
    __weak typeof(self) weakSelf = self;
    [[FLDropboxHelper sharedHelper] linkIfUnlinked:self completion:^(BOOL success) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && success) {
            if (strongSelf.presentingViewController.presentedViewController == weakSelf) {
                // dropbox panel isn't displayed, so we can go ahead and dismiss this guy
                [strongSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            } else {
                // this should dismiss on next appearance
                strongSelf.shouldDismiss = YES;
            }

            if (strongSelf.linkSuccess) {
                strongSelf.linkSuccess();
            }
        } else if (strongSelf) {
            // failed to connect! say so!
            strongSelf.titleLabel.text = ERROR_TITLE;
            strongSelf.description.text = ERROR_CAPTION;
            [strongSelf.connect setTitle:ERROR_BUTTON_LABEL forState:UIControlStateNormal];
            [strongSelf.view setNeedsLayout];
        }
    }];
}

@end
