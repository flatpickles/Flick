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
#define GUIDE_FONT [UIFont boldSystemFontOfSize:16.0f]

#define DISMISS_TEXT @"Dismiss Paste"
#define DISMISS_COLOR [UIColor colorWithRed:0.906f green:0.541f blue:0.239f alpha:1.0f]
#define UPLOAD_TEXT @"Upload Paste"
#define UPLOAD_COLOR [UIColor colorWithRed:0.239f green:0.604f blue:0.91f alpha:1.0f]
#define STATUS_BAR_COLOR [UIColor colorWithRed:0.188f green:0.482f blue:0.725f alpha:1.0f]

@interface FLGuideView ()

@property (nonatomic) UIView *dismissView;
@property (nonatomic) UIView *uploadView;

@end

@implementation FLGuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;

        // setup dismiss view
        CGRect f = self.frame;
        self.dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, f.size.height, f.size.width, GUIDE_HEIGHT)];
        self.dismissView.backgroundColor = DISMISS_COLOR;
        UILabel *dismissLabel = [[UILabel alloc] initWithFrame:self.dismissView.bounds];
        dismissLabel.font = GUIDE_FONT;
        dismissLabel.text = DISMISS_TEXT;
        dismissLabel.textAlignment = NSTextAlignmentCenter;
        [self.dismissView addSubview:dismissLabel];
        [self addSubview:self.dismissView];

        // setup upload view
        self.uploadView = [[UIView alloc] initWithFrame:CGRectMake(0, -(GUIDE_HEIGHT + [[UIApplication sharedApplication] statusBarFrame].size.height), f.size.width, GUIDE_HEIGHT + [[UIApplication sharedApplication] statusBarFrame].size.height)];
        self.uploadView.backgroundColor = UPLOAD_COLOR;
        UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.uploadView.frame.size.width, [[UIApplication sharedApplication] statusBarFrame].size.height)];
        statusBarBackground.backgroundColor = STATUS_BAR_COLOR;
        [self.uploadView addSubview:statusBarBackground];
        UILabel *uploadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, self.uploadView.frame.size.width, GUIDE_HEIGHT)];
        uploadLabel.font = GUIDE_FONT;
        uploadLabel.text = UPLOAD_TEXT;
        uploadLabel.textAlignment = NSTextAlignmentCenter;
        [self.uploadView addSubview:uploadLabel];
        [self addSubview:self.uploadView];
    }
    return self;
}

- (void)setHidden:(BOOL)hidden
{
    if (_hidden == hidden) {
        return;
    }
    _hidden = hidden;

    if (!hidden) {
        [UIView animateWithDuration:GUIDE_SHOW_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.uploadView.center = CGPointMake(self.uploadView.center.x, self.uploadView.center.y + (GUIDE_HEIGHT + [[UIApplication sharedApplication] statusBarFrame].size.height));
            self.dismissView.center = CGPointMake(self.dismissView.center.x, self.dismissView.center.y - GUIDE_HEIGHT);
        } completion:nil];
    } else {
        [UIView animateWithDuration:GUIDE_HIDE_DURATION delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            _uploadView.layer.opacity = 1.0f;
            _dismissView.layer.opacity = 1.0f;
            self.uploadView.center = CGPointMake(self.uploadView.center.x, self.uploadView.center.y - (GUIDE_HEIGHT + [[UIApplication sharedApplication] statusBarFrame].size.height));
            self.dismissView.center = CGPointMake(self.dismissView.center.x, self.dismissView.center.y + GUIDE_HEIGHT);
        } completion:nil];
    }
}

- (void)fadeRelativeToPasteOffset:(CGFloat)yOffset
{
    CGFloat maxDistance = [[UIScreen mainScreen] bounds].size.height/2;
    CGFloat newOpacity = 1 - MIN(1, ABS(yOffset) / maxDistance);
    if (yOffset > 0.0f) {
        self.dismissView.layer.opacity = 1.0f;
        self.uploadView.layer.opacity = newOpacity;
    } else {
        self.uploadView.layer.opacity = 1.0f;
        self.dismissView.layer.opacity = newOpacity;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // pass on any touch events if hidden
    return (self.hidden) ? nil : self;
}

@end
