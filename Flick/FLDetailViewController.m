//
//  FLDetailViewController.m
//  Flick
//
//  Created by Matt Nichols on 2/3/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLDetailViewController.h"
#import "FLDetailView.h"

@interface FLDetailViewController ()

@property (nonatomic) FLEntity *entity;

@end

@implementation FLDetailViewController

- (id)initWithEntity:(FLEntity *)entity
{
    self = [self init];
    if (self) {
        self.entity = entity;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:YES];

    // swipe recognizer
    UISwipeGestureRecognizer *swipeRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLeftSwipe:)];
    swipeRec.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRec];

    // maybe put view stuff in own class?
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)loadView
{
    FLDetailView *detailView = [[FLDetailView alloc] init];
    detailView.entity = self.entity;
    self.view = detailView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_handleLeftSwipe:(UISwipeGestureRecognizer *)gestureRec
{
    if (gestureRec.state == UIGestureRecognizerStateRecognized) {
        [UIView animateWithDuration:FLIP_DURATION animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
        }];
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
