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
#define TITLE_TEXT_FADE_DELAY 0.3f

#define COPY_MESSAGE @"Paste copied to clipboard"
#define COPY_LINK_MESSAGE @"Dropbox link copied to clipboard"

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
    self.historyViewController.dataSource.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.historyViewController];
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];

    // setup guide view
    self.guideView = [[FLGuideView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.guideView];

    // go go dropbox
    __weak typeof(self) weakSelf = self;
    [[FLDropboxHelper sharedHelper] linkIfUnlinked:self completion:^(BOOL success) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && success) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                strongSelf.historyViewController.dataSource.fileInfoArray = [[[FLDropboxHelper sharedHelper] fileListing] mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // make sure UI updates happen on main thread
                    [strongSelf.historyViewController.tableView reloadData];
                    [strongSelf _displayPasteView];
                });
            });
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
    if (![[FLDropboxHelper sharedHelper] canStoreObject:toStore]) {
        return;
    }

    [self.guideView hide:FLGuideDisplayTypeBoth];

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
    [self.historyViewController fadeToOpacity:1.0f withDuration:HISTORY_FADE_DURATION];
}

#pragma mark - FLPasteViewDelegate

- (BOOL)shouldStorePaste:(id)pasteObject
{
    BOOL success = [[FLDropboxHelper sharedHelper] storeObject:self.pasteView.text];
    if (success) {
        [self.guideView hide:FLGuideDisplayTypeTop];
        [self.historyViewController hideTitle:NO animate:NO];
        [self _setupForHistoryViewing];
    }

    return success;
}

- (void)didDismissPaste:(id)pasteObject
{
    [self.guideView hide:FLGuideDisplayTypeBottom delay:0.0f completion:^(BOOL finished) {
        // delay the title fade in so it doesn't overlap with the fading out "upload paste"
        [self.historyViewController hideTitle:NO animate:YES];
    }];
    [self _setupForHistoryViewing];
}

- (void)pasteViewActive
{
    // hide the title after showing so it's not visible during fade to paste offset
    [self.historyViewController hideTitle:YES animate:YES];
    [self.guideView show:FLGuideDisplayTypeBoth];
}

- (void)pasteViewReset
{
    [self.historyViewController hideTitle:NO animate:YES];
    [self.guideView hide:FLGuideDisplayTypeBoth];
}

- (void)pasteViewMoved:(CGFloat)yOffset
{
    [self.guideView fadeRelativeToPasteOffset:yOffset];
}

#pragma mark - FLHistoryActionsDelegate

- (void)didCopyEntity:(FLEntity *)entity
{
    [self.guideView displayMessage:COPY_MESSAGE];
}

- (void)didCopyLinkForFile:(DBFileInfo *)entity
{
    [self.guideView displayMessage:COPY_LINK_MESSAGE];
}

@end
