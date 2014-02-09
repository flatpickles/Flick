//
//  FLHistoryTableViewController.m
//  Flick
//
//  Created by Matt Nichols on 11/24/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import "FLHistoryTableViewController.h"
#import "FLEntity.h"

#define TITLE_FADE_IN 0.3f
#define TITLE_FADE_OUT 0.1f
#define HIDDEN_TITLE_OPACITY 0.0f
#define TITLE_FONT [UIFont boldSystemFontOfSize:18.0f]
#define TITLE_TEXT @"Your Pastes"
#define SEPARATOR_INSET 15.0f

@interface FLHistoryTableViewController ()

@property (nonatomic) UILabel *navigationLabel;

@end

@implementation FLHistoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.dataSource = [[FLHistoryDataSource alloc] init];
        self.tableView.delegate = self.dataSource;
        self.tableView.dataSource = self.dataSource;
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0f, SEPARATOR_INSET, 0.0f, SEPARATOR_INSET);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource.tableViewWidth = self.tableView.frame.size.width;

    // setup a replacement navigation label so we can control opacity directly
    self.navigationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.navigationLabel.backgroundColor = [UIColor clearColor];
    self.navigationLabel.font = TITLE_FONT;
    self.navigationLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationLabel.textColor = [UIColor blackColor];
    self.navigationLabel.text = TITLE_TEXT;
    self.navigationItem.titleView = self.navigationLabel;
    [self.navigationLabel sizeToFit];

    // set up the long press recognizer
    UILongPressGestureRecognizer *pressRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
    pressRec.minimumPressDuration = 1.0f;
    [self.tableView addGestureRecognizer:pressRec];

    // swipe recognizer
    UISwipeGestureRecognizer *swipeRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSwipe:)];
    swipeRec.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipeRec];
}

- (void)hideTitle:(BOOL)hidden animate:(BOOL)animate
{
    if (animate) {
        if (hidden) {
            [UIView animateWithDuration:TITLE_FADE_OUT delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.navigationLabel.layer.opacity = HIDDEN_TITLE_OPACITY;
            } completion:nil];
        } else {
            [UIView animateWithDuration:TITLE_FADE_IN delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.navigationLabel.layer.opacity = 1.0f;
            } completion:nil];
        }
    } else {
        self.navigationLabel.layer.opacity = (hidden) ? HIDDEN_TITLE_OPACITY : 1.0f;
    }
}

- (void)setOpacity:(CGFloat)opacity withDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.view.layer.opacity = opacity;
        // todo: should this be self.navigationController.view? That would include title
    } completion:nil];
}

- (void)addNewEntity:(DBFileInfo *)entityInfo
{
    [self.dataSource.fileInfoArray insertObject:entityInfo atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)_handleLongPress:(UILongPressGestureRecognizer *)gestureRec
{
    if (gestureRec.state == UIGestureRecognizerStateBegan) {
        // only call once per gesture
        CGPoint pt = [gestureRec locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pt];
        [self.dataSource handleLongPress:indexPath];
    }
}

- (void)_handleSwipe:(UISwipeGestureRecognizer *)gestureRec
{
    if (gestureRec.state == UIGestureRecognizerStateEnded) {
        // only call once per gesture
        CGPoint pt = [gestureRec locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pt];
        [self.dataSource handleRightSwipe:indexPath navController:self.navigationController];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
