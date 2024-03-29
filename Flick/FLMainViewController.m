//
//  FLMainViewController.m
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "FLConnectDropboxViewController.h"
#import "FLDropboxHelper.h"
#import "FLGuideView.h"
#import "FLHistoryTableViewController.h"
#import "FLMainViewController.h"
#import "FLPasteView.h"
#import "FLSettingsViewController.h"

#define AFTER_INTRO_DELAY 0.4f
#define COPY_LINK_MESSAGE @"Dropbox link copied to clipboard"
#define COPY_MESSAGE @"%@ copied to clipboard"
#define GUIDEVIEW_DISPLAY_DELAY 0.1f
#define HISTORY_BACKGROUND_OPACITY 0.5f
#define HISTORY_FADE_DURATION 0.3f
#define PASTE_FADE_DURATION 0.3f
#define PASTE_X_INSET 30.0f
#define PASTE_Y_INSET 70.0f
#define SETTINGS_FONT_COLOR [UIColor grayColor]
#define SETTINGS_FONT_SIZE 24.0f
#define STATUS_BAR_FADE_DURATION 0.3f
#define TITLE_TEXT_FADE_DELAY 0.3f

#define INTRO_DEFAULT_KEY @"userHasSeenIntroKey"
#define INTRO_TEXT @"Whenever you open Flick, one of these cards will pop up with whatever is currently copied to your clipboard. Flick up to upload it to Dropbox, or down to dismiss. Tap \u2699 for more options and usage tips. Dismiss this card to get started!"

@interface FLMainViewController ()

@property (nonatomic) UINavigationController *navigation;
@property (nonatomic) FLHistoryTableViewController *historyViewController;
@property (nonatomic) FLSettingsViewController *settingsViewController;
@property (atomic) FLPasteView *pasteView;
@property (atomic) FLGuideView *guideView;
@property (nonatomic) BOOL shouldDisplayGuide;
@property (nonatomic) UIBarButtonItem *addButton;
@property (nonatomic) BOOL isDisplayingIntro;

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
    self.navigation.delegate = self;

    // set up add button
    self.addButton = [[UIBarButtonItem alloc] initWithTitle:@"\uFF0B" style:UIBarButtonItemStylePlain target:self action:@selector(_displayPasteboardObject)];
    [self.addButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:SETTINGS_FONT_SIZE], NSForegroundColorAttributeName: SETTINGS_FONT_COLOR} forState:UIControlStateNormal];

    // set up settings
    self.settingsViewController = [[FLSettingsViewController alloc] init];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(_displaySettings)];
    [settingsButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:SETTINGS_FONT_SIZE], NSForegroundColorAttributeName: SETTINGS_FONT_COLOR} forState:UIControlStateNormal];
    self.historyViewController.navigationItem.rightBarButtonItem = settingsButton;

    // setup guide view
    self.guideView = [[FLGuideView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.guideView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // show dropbox connect if need be
    if (![[FLDropboxHelper sharedHelper] isLinked]) {
        FLConnectDropboxViewController *connect = [[FLConnectDropboxViewController alloc] init];
        [self.navigation setNavigationBarHidden:YES animated:YES];
        [self.navigation presentViewController:connect animated:YES completion:nil];
    } else {
        [self.navigation setNavigationBarHidden:NO animated:YES];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // will be executed on appearance or after linking to dropbox (and this once again appears)
            typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                [self becomeFirstResponder];
                [FLDropboxHelper sharedHelper].guideView = self.guideView;
                strongSelf.historyViewController.dataSource.fileInfoArray = [[[FLDropboxHelper sharedHelper] fileListing] mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // make sure UI updates happen on main thread
                    [strongSelf.historyViewController.tableView reloadData];
                    BOOL shouldShowIntro = ![[NSUserDefaults standardUserDefaults] boolForKey:INTRO_DEFAULT_KEY];
                    if (shouldShowIntro) {
                        [strongSelf _displayIntro];
                    } else {
                        [strongSelf _displayPasteboardObject];
                    }
                });
            }
        });
    }
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

- (void)_displayPasteboardObject
{
    self.isDisplayingIntro = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id pasteboardObject = ([UIPasteboard generalPasteboard].image) ? [UIPasteboard generalPasteboard].image : [UIPasteboard generalPasteboard].string;
        if (pasteboardObject) {
            [self _displayPasteViewWithObject:pasteboardObject];
        }
    });
}

- (void)_displayLastPhoto
{
    self.isDisplayingIntro = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        __weak typeof(self) weakSelf = self;
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group && group.numberOfAssets > 0) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    typeof(self) strongSelf = weakSelf;
                    if (result && strongSelf) {
                        ALAssetRepresentation *rep = [result defaultRepresentation];

                        // Retrieve the image orientation from the ALAsset
                        UIImageOrientation orientation = UIImageOrientationUp;
                        NSNumber* orientationValue = [result valueForProperty:@"ALAssetPropertyOrientation"];
                        if (orientationValue != nil) {
                            orientation = [orientationValue intValue];
                        }

                        UIImage* image = [UIImage imageWithCGImage:[rep fullResolutionImage] scale:1.0f orientation:orientation];

                        // UI stuff will happen on main thread within _displayPasteViewWithObject
                        [strongSelf _displayPasteViewWithObject:image];
                        *stop = YES;
                    }
                }];
                *stop = YES;
            }
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"Looks like you’ve denied access to your photos. Visit the photos section of your privacy settings to enable." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            });
        }];
    });
}

- (void)_displayIntro
{
    self.isDisplayingIntro = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:INTRO_DEFAULT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self _displayPasteViewWithObject:INTRO_TEXT];
    });
}

- (void)_introWasDisplayed
{
    double delayInSeconds = AFTER_INTRO_DELAY;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self _displayPasteboardObject];
    });
}

- (void)_displayPasteViewWithObject:(id)object
{
    // should be called on background thread, canStoreObject is slow
    // check if we should (if the thing displayed has already been stored, dropbox is good to go, main view is forefront)
    if (![DBFilesystem sharedFilesystem] || ![[FLDropboxHelper sharedHelper] canStoreObject:object] || [self.navigation topViewController] != self.historyViewController) {
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
        [self _updateAddButtonForceHidden:YES];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // setup the pasteview if necessary, on the main thread
        if (!self.pasteView) {
            CGRect frame = self.view.bounds;
            self.pasteView = [[FLPasteView alloc] initWithFrame:CGRectInset(frame, PASTE_X_INSET, PASTE_Y_INSET)];
            self.pasteView.delegate = self;
            [self.view addSubview:self.pasteView];
        } else if (self.pasteView.isDisplayed) {
            if (![self.pasteView.entity isEqualToEntity:entityToDisplay]) {
                [self.pasteView animateExitWithCompletion:displayBlock];
            }
            return;
        }
        displayBlock();
    });
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

- (void)_updateAddButtonForceHidden:(BOOL)hidden
{
    if (hidden) {
        // force hide, avoid DB check. Can be used for faster evaluation.
        [self.historyViewController.navigationItem setLeftBarButtonItem:nil animated:YES];
        return;
    }

    id pasteboardObject = ([UIPasteboard generalPasteboard].image) ? [UIPasteboard generalPasteboard].image : ([[UIPasteboard generalPasteboard].string length] > 0) ? [UIPasteboard generalPasteboard].string : nil;
    if (pasteboardObject != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL display = !self.pasteView.isDisplayed && [DBFilesystem sharedFilesystem] && [[FLDropboxHelper sharedHelper] canStoreObject:pasteboardObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.historyViewController.navigationItem setLeftBarButtonItem:(display ? self.addButton : nil) animated:YES];
            });
        });
    }
}

#pragma mark - FLPasteViewDelegate

- (void)shouldStorePaste:(FLEntity *)pasteEntity
{
    // dismiss pasteview
    [self.guideView hide:FLGuideDisplayTypeTop];
    [self.historyViewController hideTitle:NO animate:NO];
    [self _setupForHistoryViewing];


    // upload and display file
    __weak typeof(self) weakSelf = self;
    [[FLDropboxHelper sharedHelper] storeEntity:pasteEntity completion:^(DBFileInfo *info) {
        typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            if (info) {
                [strongSelf.historyViewController addNewEntity:info];
                if (!self.isDisplayingIntro) {
                    [self _updateAddButtonForceHidden:NO];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:COPY_LINK_ON_UPLOAD_KEY]) {
                    [[FLDropboxHelper sharedHelper] copyLinkForFile:info delegate:self];
                }
            }
        }
    }];

    if (self.isDisplayingIntro) {
        [self _introWasDisplayed];
    }
}

- (void)didDismissPaste:(FLEntity *)pasteEntity
{
    self.shouldDisplayGuide = NO;
    [self.guideView hide:FLGuideDisplayTypeBottom delay:0.0f completion:^(BOOL finished) {
        // delay the title fade in so it doesn't overlap with the fading out "upload paste"
        [self.historyViewController hideTitle:NO animate:YES];
    }];
    [self _setupForHistoryViewing];


    if (self.isDisplayingIntro) {
        [self _introWasDisplayed];
    } else {
        [self _updateAddButtonForceHidden:NO];
    }
}

- (void)pasteViewActive
{
    self.shouldDisplayGuide = YES;
    // hide the title after showing so it's not visible during fade to paste offset
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(GUIDEVIEW_DISPLAY_DELAY * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.shouldDisplayGuide) {
            [self.historyViewController hideTitle:YES animate:YES];
            [self.guideView show:FLGuideDisplayTypeBoth];
        }
    });
}

- (void)pasteViewReset
{
    self.shouldDisplayGuide = NO;
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
    [self _updateAddButtonForceHidden:YES];
}

- (void)didCopyLinkForFile:(DBFileInfo *)entity
{
    [self.guideView displayMessage:COPY_LINK_MESSAGE];
    [self _updateAddButtonForceHidden:YES];
}

- (void)didDeleteFile
{
    [self _updateAddButtonForceHidden:NO];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[FLHistoryTableViewController class]]) {
        // whenever the history view controller is shown, update the button
        [self _updateAddButtonForceHidden:NO];
    }
}

@end
