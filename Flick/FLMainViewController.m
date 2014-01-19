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
#import "FLGuideView.h"

#define HISTORY_BACKGROUND_OPACITY 0.5f
#define HISTORY_FADE_DURATION 0.3f
#define STATUS_BAR_FADE_DURATION 0.3f
#define PASTE_X_INSET 30.0f
#define PASTE_Y_INSET 70.0f

@interface FLMainViewController ()

@property FLPasteView *pasteView;
@property FLHistoryTableViewController *historyViewController;
@property FLGuideView *guideView;

@end

@implementation FLMainViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_displayPasteView) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
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

    // setup guide view
    self.guideView = [[FLGuideView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.guideView];

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_displayPasteView
{
    // check if we should (if the thing displayed has already been stored)
    id toStore = [UIPasteboard generalPasteboard].string; // todo: make this smarter
    if ([[FLDropboxHelper sharedHelper] isStored:toStore]) {
        return;
    }

    self.guideView.hidden = YES;

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

- (void)_setupForHistoryViewing
{
    self.historyViewController.titleHidden = NO;
    [self.historyViewController fadeToOpacity:1.0f withDuration:HISTORY_FADE_DURATION];
    self.guideView.hidden = YES;
}

#pragma mark - FLPasteViewDelegate

- (BOOL)shouldStorePaste:(id)pasteObject
{
    BOOL success = [[FLDropboxHelper sharedHelper] storeObject:self.pasteView.text];
    if (success) {
        [self _setupForHistoryViewing];
    }

    return success;
}

- (void)didDismissPaste:(id)pasteObject
{
    [self _setupForHistoryViewing];
}

- (void)pasteViewActive
{
    self.historyViewController.titleHidden = YES;
    self.guideView.hidden = NO;
}

- (void)pasteViewReset
{
    self.guideView.hidden = YES;
    self.historyViewController.titleHidden = NO;
}

- (void)pasteViewMoved:(CGFloat)yOffset
{
    [self.guideView fadeRelativeToPasteOffset:yOffset];
}

@end
