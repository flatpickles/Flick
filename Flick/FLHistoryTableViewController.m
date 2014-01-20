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
#define HIDDEN_TITLE_OPACITY 0.15f

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
    self.navigationLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.navigationLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationLabel.textColor = [UIColor blackColor];
    self.navigationLabel.text = @"Your Previous Pastes";
    self.navigationItem.titleView = self.navigationLabel;
    [self.navigationLabel sizeToFit];

    // set up the long press recognizer
    UILongPressGestureRecognizer *gestureRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
    gestureRec.minimumPressDuration = 1.0f;
    [self.tableView addGestureRecognizer:gestureRec];
}

- (void)setTitleHidden:(BOOL)titleHidden
{
    _titleHidden = titleHidden;
    if (titleHidden) {
        [UIView animateWithDuration:TITLE_FADE_OUT animations:^{
            self.navigationLabel.layer.opacity = HIDDEN_TITLE_OPACITY;
        }];
    } else {
        [UIView animateWithDuration:TITLE_FADE_IN animations:^{
            self.navigationLabel.layer.opacity = 1.0f;
        }];
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
