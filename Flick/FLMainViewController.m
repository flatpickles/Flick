//
//  FLMainViewController.m
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import "FLMainViewController.h"
#import "FLPasteView.h"
#import "FLHistoryTableViewController.h"
#import "FLDropboxHelper.h"

#define HISTORY_BACKGROUND_OPACITY 0.5f
#define HISTORY_FADE_DURATION 0.3f
#define STATUS_BAR_FADE_DURATION 0.3f
#define PASTE_X_INSET 30.0f
#define PASTE_Y_INSET 70.0f
#define GUIDE_HEIGHT 50.0f
#define GUIDE_SHOW_DURATION 0.2f
#define GUIDE_HIDE_DURATION 0.5f

@interface FLMainViewController ()

@property FLPasteView *pasteView;
@property FLHistoryTableViewController *historyViewController;
@property UIView *dismissView;
@property UIView *uploadView;
@property (nonatomic) BOOL displayGuide;

@end

@implementation FLMainViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // setup history view
    self.historyViewController = [[FLHistoryTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.historyViewController];
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];

    // setup dismiss view
    CGRect f = self.view.frame;
    _dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, f.size.height, f.size.width, GUIDE_HEIGHT)];
    _dismissView.backgroundColor = [UIColor redColor];
    UILabel *dismissLabel = [[UILabel alloc] initWithFrame:_dismissView.bounds];
    dismissLabel.text = @"Dismiss";
    dismissLabel.textAlignment = NSTextAlignmentCenter;
    [_dismissView addSubview:dismissLabel];
    [self.view addSubview:_dismissView];

    // setup upload view
    _uploadView = [[UIView alloc] initWithFrame:CGRectMake(0, -GUIDE_HEIGHT, f.size.width, GUIDE_HEIGHT)];
    _uploadView.backgroundColor = [UIColor greenColor];
    UILabel *uploadLabel = [[UILabel alloc] initWithFrame:_uploadView.bounds];
    uploadLabel.text = @"Upload";
    uploadLabel.textAlignment = NSTextAlignmentCenter;
    [_uploadView addSubview:uploadLabel];
    [self.view addSubview:_uploadView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setDisplayGuide:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // go go dropbox
    [[FLDropboxHelper sharedHelper] linkIfUnlinked:self completion:^(BOOL success) {
        // todo: weakself strongself etc
        if (success) {
            self.historyViewController.backingData = [[FLDropboxHelper sharedHelper] storedObjects];
            // todo: don't get object list on main thread
            [self.historyViewController.tableView reloadData];
            [self _displayPasteView];
        }
    }];

    // todo: not in initializer bc it would call this before linking... but should it be here?
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_displayPasteView) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return _displayGuide;
}

- (void)setDisplayGuide:(BOOL)displayGuide
{
    if (displayGuide == _displayGuide) {
        return;
    }

    _displayGuide = displayGuide;
    if (displayGuide) {
        [UIView animateWithDuration:GUIDE_SHOW_DURATION animations:^{
            _uploadView.center = CGPointMake(_uploadView.center.x, _uploadView.center.y + GUIDE_HEIGHT);
            _dismissView.center = CGPointMake(_dismissView.center.x, _dismissView.center.y - GUIDE_HEIGHT);
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    } else {
        [UIView animateWithDuration:GUIDE_HIDE_DURATION animations:^{
            _uploadView.center = CGPointMake(_uploadView.center.x, _uploadView.center.y - GUIDE_HEIGHT);
            _dismissView.center = CGPointMake(_dismissView.center.x, _dismissView.center.y + GUIDE_HEIGHT);
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
}

- (void)_displayPasteView
{
    // check if we should (if the thing displayed has already been stored)
    id toStore = [UIPasteboard generalPasteboard].string; // todo: make this smarter
    if ([[FLDropboxHelper sharedHelper] isStored:toStore]) {
        return;
    }

    [self setDisplayGuide:YES];

    // setup the pasteview if necessary
    if (!self.pasteView) {
        CGRect frame = self.view.bounds;
        self.pasteView = [[FLPasteView alloc] initWithFrame:CGRectInset(frame, PASTE_X_INSET, PASTE_Y_INSET)];
        self.pasteView.delegate = self;
        [self.view addSubview:self.pasteView];
    }

    // configure
    [self.pasteView resetWithAnimations:NO];
    self.historyViewController.view.layer.opacity = HISTORY_BACKGROUND_OPACITY;

    // set content
    self.pasteView.text = [UIPasteboard generalPasteboard].string;
}

#pragma mark - FLPasteViewDelegate

-(BOOL)shouldStorePaste:(id)pasteObject
{
    BOOL success = [[FLDropboxHelper sharedHelper] storeObject:self.pasteView.text];
    if (success) {
        [self.historyViewController fadeToOpacity:1.0f withDuration:HISTORY_FADE_DURATION];
        [self setDisplayGuide:NO];
    }

    return success;
}

-(void)didDismissPaste:(id)pasteObject
{
    [self.historyViewController fadeToOpacity:1.0f withDuration:HISTORY_FADE_DURATION];
    [self setDisplayGuide:NO];
}

@end
