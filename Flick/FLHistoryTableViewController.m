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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    UILongPressGestureRecognizer *gestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
    gestureRec.minimumPressDuration = 1.0f;
    [self.tableView addGestureRecognizer:gestureRec];
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

- (void)fadeToOpacity:(CGFloat)opacity withDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.view.layer.opacity = opacity;
    } completion:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
