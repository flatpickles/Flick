//
//  FLMainViewController.m
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "FLMainViewController.h"
#import "FLPasteView.h"
#import "FLHistoryTableViewController.h"
#import "FLDropboxHelper.h"
#import "FLGuideView.h"
#import "FLSettingsViewController.h"

#define HISTORY_BACKGROUND_OPACITY 0.5f
#define HISTORY_FADE_DURATION 0.3f
#define PASTE_FADE_DURATION 0.3f
#define STATUS_BAR_FADE_DURATION 0.3f
#define PASTE_X_INSET 30.0f
#define PASTE_Y_INSET 70.0f
#define TITLE_TEXT_FADE_DELAY 0.3f

#define COPY_MESSAGE @"%@ copied to clipboard"
#define COPY_LINK_MESSAGE @"Dropbox link copied to clipboard"

@interface FLMainViewController ()

@property UINavigationController *navigation;
@property FLPasteView *pasteView;
@property FLHistoryTableViewController *historyViewController;
@property FLSettingsViewController *settingsViewController;
@property FLGuideView *guideView;

@end

@implementation FLMainViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_displayPasteboardObject) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // setup history view
    self.historyViewController = [[FLHistoryTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.historyViewController.dataSource.delegate = self;
    self.navigation = [[UINavigationController alloc] initWithRootViewController:self.historyViewController];
    [self addChildViewController:self.navigation];
    [self.view addSubview:self.navigation.view];

    // set up settings
    self.settingsViewController = [[FLSettingsViewController alloc] init];
    self.historyViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(_displaySettings)];

    // setup guide view
    self.guideView = [[FLGuideView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.guideView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];

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
                    [strongSelf _displayPasteboardObject];
                });
            });
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake && [[NSUserDefaults standardUserDefaults] boolForKey:SHAKE_TO_USE_PHOTO_KEY]) {
        [self _displayLastPhoto];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_displayPasteboardObject
{
    id pasteboardObject = ([UIPasteboard generalPasteboard].image) ? [UIPasteboard generalPasteboard].image : [UIPasteboard generalPasteboard].string;
    [self _displayPasteViewWithObject:pasteboardObject];
}

- (void)_displayLastPhoto
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __weak typeof(self) weakSelf = self;
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group && group.numberOfAssets > 0) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                typeof(weakSelf) strongSelf = weakSelf;
                if (result && strongSelf) {
                    ALAssetRepresentation *rep = [result defaultRepresentation];

                    // Retrieve the image orientation from the ALAsset
                    UIImageOrientation orientation = UIImageOrientationUp;
                    NSNumber* orientationValue = [result valueForProperty:@"ALAssetPropertyOrientation"];
                    if (orientationValue != nil) {
                        orientation = [orientationValue intValue];
                    }

                    UIImage* image = [UIImage imageWithCGImage:[rep fullResolutionImage] scale:1.0f orientation:orientation];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // UI stuff on main thread
                        [strongSelf _displayPasteViewWithObject:image];
                    });
                    *stop = YES;
                }
            }];
            *stop = YES;
        }
    } failureBlock:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"Looks like you've denied access to your photos. Visit the photos section of your privacy settings to re-enable." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)_displayPasteViewWithObject:(id)object
{
    // check if we should (if the thing displayed has already been stored, dropbox is good to go)
    if (![DBFilesystem sharedFilesystem] || ![[FLDropboxHelper sharedHelper] canStoreObject:object]) {
        return;
    }

    FLEntity *entityToDisplay = [[FLEntity alloc] initWithObject:object];
    void (^displayBlock)(void) = ^(void) {
        // configure
        [self.historyViewController setOpacity:HISTORY_BACKGROUND_OPACITY withDuration:PASTE_FADE_DURATION];
        self.navigation.view.userInteractionEnabled = NO;

        // set content
        self.pasteView.entity = entityToDisplay;
        [self.pasteView fadeIn:PASTE_FADE_DURATION];
    };

    // setup the pasteview if necessary
    if (!self.pasteView) {
        CGRect frame = self.view.bounds;
        self.pasteView = [[FLPasteView alloc] initWithFrame:CGRectInset(frame, PASTE_X_INSET, PASTE_Y_INSET)];
        self.pasteView.delegate = self;
        [self.view addSubview:self.pasteView];
    } else if (self.pasteView.isDisplayed) {
        if (![self.pasteView.entity isEqualToEntity:self.pasteView.entity]) {
            [self.pasteView animateExitWithCompletion:displayBlock];
        }
        return;
    }
    
    displayBlock();
}

- (void)_displaySettings
{
    [self.navigation pushViewController:self.settingsViewController animated:YES];
}

- (void)_setupForHistoryViewing
{
    [self.historyViewController setOpacity:1.0f withDuration:HISTORY_FADE_DURATION];
    self.navigation.view.userInteractionEnabled = YES;
}

#pragma mark - FLPasteViewDelegate

- (void)shouldStorePaste:(FLEntity *)pasteEntity
{
    __weak typeof(self) weakSelf = self;
    [[FLDropboxHelper sharedHelper] storeEntity:pasteEntity completion:^(DBFileInfo *info) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.guideView hide:FLGuideDisplayTypeTop];
            [strongSelf.historyViewController hideTitle:NO animate:NO];
            [strongSelf _setupForHistoryViewing];

            if (info) {
                // todo: display success
                [strongSelf.historyViewController addNewEntity:info];
                if ([[NSUserDefaults standardUserDefaults] boolForKey:COPY_LINK_ON_UPLOAD_KEY]) {
                    [[FLDropboxHelper sharedHelper] copyLinkForFile:info delegate:self];
                }
            } else {
                // todo: display error
            }
        }
    }];
}

- (void)didDismissPaste:(FLEntity *)pasteEntity
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
    [self.guideView displayMessage:[NSString stringWithFormat:COPY_MESSAGE, (entity.type == TextEntity) ? @"Text" : @"Image"]];
}

- (void)didCopyLinkForFile:(DBFileInfo *)entity
{
    [self.guideView displayMessage:COPY_LINK_MESSAGE];
}

@end
