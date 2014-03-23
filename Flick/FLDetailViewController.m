//
//  FLDetailViewController.m
//  Flick
//
//  Created by Matt Nichols on 2/3/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLDetailView.h"
#import "FLDetailViewController.h"

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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    // swipe recognizers
    UISwipeGestureRecognizer *swipeRecLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissLeft:)];
    swipeRecLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecLeft];
    UISwipeGestureRecognizer *swipeRecRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissRight:)];
    swipeRecRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRecRight];

    // tap recognizer
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismiss:)];
    tapRec.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRec];
}

- (void)loadView
{
    FLDetailView *detailView = [[FLDetailView alloc] init];
    detailView.entity = self.entity;
    self.view = detailView;
}

- (void)_dismissRight:(UISwipeGestureRecognizer *)gestureRec
{
    if (gestureRec.state == UIGestureRecognizerStateRecognized) {
        [self _dismiss:NO];
    }
}

- (void)_dismissLeft:(UISwipeGestureRecognizer *)gestureRec
{
    if (gestureRec.state == UIGestureRecognizerStateRecognized) {
        [self _dismiss:YES];
    }

}

- (void)_dismiss:(BOOL)flipRight
{
    [UIView animateWithDuration:FLIP_DURATION animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:((flipRight) ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.navigationController.view cache:NO];
    }];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

@end
