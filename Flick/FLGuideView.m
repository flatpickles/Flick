//
//  FLGuideView.m
//  Flick
//
//  Created by Matt Nichols on 1/19/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLGuideView.h"

#define GUIDE_HEIGHT 45.0f
#define GUIDE_SHOW_DURATION 0.15f
#define GUIDE_HIDE_DURATION 0.3f
#define GUIDE_TOP_TEXT_HIDE_DURATION 0.1f
#define GUIDE_FONT [UIFont boldSystemFontOfSize:16.0f]
#define MESSAGE_DISPLAY_DURATION 0.7f

#define DISMISS_TEXT @"Dismiss Paste"
#define DISMISS_COLOR [UIColor colorWithRed:0.906f green:0.541f blue:0.239f alpha:1.0f]
#define UPLOAD_TEXT @"Upload Paste"
#define UPLOAD_COLOR [UIColor colorWithRed:0.239f green:0.604f blue:0.91f alpha:1.0f]
#define STATUS_BAR_COLOR [UIColor colorWithRed:0.188f green:0.482f blue:0.725f alpha:1.0f]

@interface FLGuideView ()

@property (nonatomic) UIView *bottomView;
@property (nonatomic) CGPoint originalDismissCenter;
@property (nonatomic) UIView *topView;
@property (nonatomic) UIView *topBackgroundView;
@property (nonatomic) UILabel *topLabel;
@property (nonatomic) CGPoint originalUploadCenter;
@property (nonatomic) BOOL hidden;

@end

@implementation FLGuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;

        // setup dismiss view
        CGRect f = self.frame;
        self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, f.size.height, f.size.width, GUIDE_HEIGHT)];
        self.bottomView.backgroundColor = DISMISS_COLOR;
        UILabel *dismissLabel = [[UILabel alloc] initWithFrame:self.bottomView.bounds];
        dismissLabel.font = GUIDE_FONT;
        dismissLabel.text = DISMISS_TEXT;
        dismissLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:dismissLabel];
        [self addSubview:self.bottomView];
        self.originalDismissCenter = self.bottomView.center;

        // setup upload view
        self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, -(GUIDE_HEIGHT + [[UIApplication sharedApplication] statusBarFrame].size.height), f.size.width, GUIDE_HEIGHT + [[UIApplication sharedApplication] statusBarFrame].size.height)];
        self.topView.backgroundColor = [UIColor clearColor];
        self.topBackgroundView = [[UIView alloc] initWithFrame:self.topView.bounds];
        self.topBackgroundView.backgroundColor = UPLOAD_COLOR;
        UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.topView.frame.size.width, [[UIApplication sharedApplication] statusBarFrame].size.height)];
        statusBarBackground.backgroundColor = STATUS_BAR_COLOR;
        [self.topBackgroundView addSubview:statusBarBackground];
        [self.topView addSubview:self.topBackgroundView];
        self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, self.topView.frame.size.width, GUIDE_HEIGHT)];
        self.topLabel.font = GUIDE_FONT;
        self.topLabel.text = UPLOAD_TEXT;
        self.topLabel.textAlignment = NSTextAlignmentCenter;
        [self.topView addSubview:self.topLabel];
        [self addSubview:self.topView];
        self.originalUploadCenter = self.topView.center;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // pass on any touch events if hidden
    return (self.hidden) ? nil : self;
}

- (void)fadeRelativeToPasteOffset:(CGFloat)yOffset
{
    CGFloat maxDistance = [[UIScreen mainScreen] bounds].size.height/2;
    CGFloat newOpacity = 1 - MIN(1, ABS(yOffset) / maxDistance);
    if (yOffset > 0.0f) {
        self.bottomView.layer.opacity = 1.0f;
        self.topBackgroundView.layer.opacity = newOpacity;
    } else {
        self.topBackgroundView.layer.opacity = 1.0f;
        self.bottomView.layer.opacity = newOpacity;
    }
}

- (void)show:(FLGuideDisplayType)displayType
{
    [self show:displayType delay:0.0f completion:nil];
}

- (void)hide:(FLGuideDisplayType)displayType
{
    [self hide:displayType delay:0.0f completion:nil];
}

- (void)show:(FLGuideDisplayType)displayType delay:(CGFloat)delay completion:(void (^)(BOOL finished))completion
{
    self.hidden = NO;

    // reset everything just in case
    self.topView.center = self.originalUploadCenter;
    self.bottomView.center = self.originalDismissCenter;
    self.topView.layer.opacity = 1.0f;
    self.topBackgroundView.layer.opacity = 1.0f;
    self.bottomView.layer.opacity = 1.0f;

    [UIView animateWithDuration:GUIDE_SHOW_DURATION delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (displayType == FLGuideDisplayTypeBoth || displayType == FLGuideDisplayTypeTop) {
            self.topView.center = CGPointMake(self.topView.center.x, self.originalUploadCenter.y + (GUIDE_HEIGHT + [[UIApplication sharedApplication] statusBarFrame].size.height));
        }
        if (displayType == FLGuideDisplayTypeBoth || displayType == FLGuideDisplayTypeBottom) {
            self.bottomView.center = CGPointMake(self.bottomView.center.x, self.originalDismissCenter.y - GUIDE_HEIGHT);
        }
    } completion:completion];
}

- (void)hide:(FLGuideDisplayType)displayType delay:(CGFloat)delay completion:(void (^)(BOOL finished))completion
{
    self.hidden = YES;

    [UIView animateWithDuration:GUIDE_HIDE_DURATION delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (displayType == FLGuideDisplayTypeBoth || displayType == FLGuideDisplayTypeTop) {
            self.topBackgroundView.layer.opacity = 1.0f;
            self.topView.center = self.originalUploadCenter;
            self.bottomView.center = self.originalDismissCenter;
        }
        if (displayType == FLGuideDisplayTypeBoth || displayType == FLGuideDisplayTypeBottom) {
            self.bottomView.layer.opacity = 1.0f;
            self.bottomView.center = self.originalDismissCenter;
        }
    } completion:completion];

    if (displayType == FLGuideDisplayTypeBottom) {
        [UIView animateWithDuration:GUIDE_TOP_TEXT_HIDE_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.topView.layer.opacity = 0.0f;
        } completion:nil];
    }
}

- (void)displayMessage:(NSString *)message
{
    if (!self.hidden) {
        return;
    }

    self.topLabel.text = message;
    [self show:FLGuideDisplayTypeTop delay:0.0f completion:^(BOOL finished) {
        [self hide:FLGuideDisplayTypeTop delay:MESSAGE_DISPLAY_DURATION completion:^(BOOL finished) {
            self.topLabel.text = UPLOAD_TEXT;
        }];
    }];
}

@end
