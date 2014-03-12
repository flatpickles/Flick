//
//  FLPasteView.m
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "FLPasteView.h"

#define AUTO_SWIPE_DURATION 0.5f
#define CONTENT_INSET 30.0f
#define CORNER_RADIUS 5.0f
#define EXIT_ANIMATION_DURATION 0.3f
#define EXIT_DISTANCE 960.0f
#define MIN_SIZE CGSizeMake(200.0f, 200.0f)
#define MORE_TEXT_GRADIENT_START 0.7f
#define RETURN_SPEED 0.25f
#define SCALE_FACTOR 1.04f
#define SHADOW_GROW_KEY @"ShadowGrow"
#define SHADOW_OPACITY 0.7f
#define SHADOW_RADIUS 3.0f
#define SHADOW_SCALE_FACTOR 2.0f
#define SHADOW_SHRINK_KEY @"ShadowShrink"
#define START_SPEED 0.05f
#define SWIPE_VELOCITY_THRESHOLD 2000.0f

@interface FLPasteView ()

@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) NSDate *offsetLastSet;
@property (nonatomic) UILabel *textView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) CGPoint lastVelocity;

@end

@implementation FLPasteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        // offset center for status bar
        self.center = CGPointMake(self.center.x, self.center.y + [[UIApplication sharedApplication] statusBarFrame].size.height/2);

        self.originalCenter = self.center;
        self.originalFrame = self.frame;

        CALayer *layer = self.layer;
        [layer setShadowColor:[UIColor blackColor].CGColor];
        [layer setShadowOpacity:SHADOW_OPACITY];
        [layer setShadowRadius:SHADOW_RADIUS];
        [layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
        self.layer.cornerRadius = CORNER_RADIUS;

        UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_gotDatPan:)];
        [self addGestureRecognizer:panner];

        UIViewAutoresizing subviewResizing = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;

        self.textView = [[UILabel alloc] init];
        self.textView.numberOfLines = 0;
        self.textView.lineBreakMode = NSLineBreakByWordWrapping;
        self.textView.autoresizingMask = subviewResizing;
        [self addSubview:self.textView];

        self.imageView = [[UIImageView alloc] init];
        self.imageView.autoresizingMask = subviewResizing;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:START_SPEED delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeScale(SCALE_FACTOR, SCALE_FACTOR);
    } completion:^(BOOL finished) {
        if (finished && self.displayed) {
            [self.delegate pasteViewActive];
        }
    }];
    [self _shadowGrow];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self _resetWithAnimations:YES];
}

- (void)setEntity:(FLEntity *)entity
{
    _entity = entity;

    self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    self.frame = self.originalFrame; // so subviews will be positioned with offsets independent of previous state

    UIView *displayView;
    if (entity.type == TextEntity) {
        [self _layoutText:entity.text];
        displayView = self.textView;
    } else {
        [self _layoutImage:entity.image];
        displayView = self.imageView;
    }

    CGRect minRect = CGRectMake(self.bounds.size.width/2 - MIN_SIZE.width/2, self.bounds.size.height/2 - MIN_SIZE.height/2, MIN_SIZE.width, MIN_SIZE.height);
    self.frame = CGRectUnion(minRect, CGRectInset([displayView convertRect:displayView.bounds toView:self], -CONTENT_INSET, -CONTENT_INSET));
}

- (void)_layoutImage:(UIImage *)image
{
    self.textView.layer.opacity = 0.0f;
    self.imageView.layer.opacity = 1.0f;

    self.imageView.image = image;
    CGRect imageSize = AVMakeRectWithAspectRatioInsideRect(image.size, CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET));

    BOOL photoTooSmall = image.size.width < imageSize.size.width && image.size.height < imageSize.size.height;
    self.imageView.contentMode = (photoTooSmall) ? UIViewContentModeCenter : UIViewContentModeScaleAspectFit;
    self.imageView.frame = imageSize;
}

- (void)_layoutText:(NSString *)text
{
    self.textView.layer.opacity = 1.0f;
    self.imageView.layer.opacity = 0.0f;

    UILabel *tv = self.textView;
    tv.layer.mask = nil;
    tv.frame = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);
    tv.text = text;
    [tv sizeToFit];
    CGFloat maxHeight = self.bounds.size.height - 2 * CONTENT_INSET;
    if (tv.frame.size.height > maxHeight) {
        tv.frame = CGRectMake(0, 0, tv.frame.size.width, maxHeight);
        // set a gradient mask to indicate more text below...
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = tv.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
        gradient.startPoint = CGPointMake(0.5f, MORE_TEXT_GRADIENT_START);
        tv.layer.mask = gradient;
    }

    tv.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)fadeIn:(CGFloat)duration
{
    if (self.displayed) {
        return;
    }

    self.layer.opacity = 0.0f;
    [self _resetWithAnimations:NO];
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.layer.opacity = 1.0f;
    } completion:nil];
}

- (void)animateExitWithCompletion:(void (^)())completion
{
    [UIView animateWithDuration:EXIT_ANIMATION_DURATION animations:^{
        self.center = CGPointMake(self.center.x, self.center.y + [[UIScreen mainScreen] bounds].size.height);
    } completion:^(BOOL finished) {
        self.displayed = NO;
        completion();
    }];
}

- (void)_resetWithAnimations:(BOOL)animate
{
    // return to original position
    if (animate) {
        [UIView animateWithDuration:RETURN_SPEED delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.center = self.originalCenter;
            self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:nil];
        [self _shadowShrink];
    } else {
        self.center = self.originalCenter;
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [self.layer setShadowRadius:SHADOW_RADIUS];
    }
    self.displayed = YES;
    [self.delegate pasteViewReset];
}

- (void)_endAnimation
{
    CGFloat velocity = sqrt(pow(self.lastVelocity.x, 2.0) + pow(self.lastVelocity.y, 2.0));
    BOOL shouldAutoDismiss = self.center.y < AUTO_SWIPE_DISTANCE || self.center.y > [[UIScreen mainScreen] bounds].size.height - AUTO_SWIPE_DISTANCE;
    if (velocity < SWIPE_VELOCITY_THRESHOLD && !shouldAutoDismiss) {
        [self _resetWithAnimations:YES];
    } else {
        CGPoint target;
        NSTimeInterval duration;
        if (shouldAutoDismiss) {
            target = CGPointMake(0, ((self.center.y > [[UIScreen mainScreen] bounds].size.height/2) ? EXIT_DISTANCE : - EXIT_DISTANCE));
            duration = AUTO_SWIPE_DURATION;
        } else {
            // continue animation in the direction of last swipe, at the right speed
            CGFloat theta = atan2f(self.lastVelocity.y, 0.0f);
            target = CGPointMake(EXIT_DISTANCE * cosf(theta), EXIT_DISTANCE * sinf(theta));
            duration = EXIT_DISTANCE / velocity;
        }

        [self.delegate pasteViewMoved:target.y - self.originalCenter.y];
        BOOL dismissed = target.y > [[UIScreen mainScreen] bounds].size.height/2;
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.center = CGPointMake(self.center.x + target.x, self.center.y + target.y);
            if (dismissed) {
                // handle it right away
                [self _handleExit];
            }
        } completion:^(BOOL finished) {
            if (!dismissed) {
                // more performance heavy to upload, wait until it's off the screen
                [self _handleExit];
            }
        }];
    }
}

- (void)_shadowGrow
{
    CABasicAnimation *shadowGrowAnim = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    shadowGrowAnim.delegate = self;
    [shadowGrowAnim setFromValue:[NSNumber numberWithFloat:SHADOW_RADIUS]];
    [shadowGrowAnim setToValue:[NSNumber numberWithFloat:SHADOW_RADIUS * SHADOW_SCALE_FACTOR]];
    [shadowGrowAnim setDuration:START_SPEED];

    shadowGrowAnim.removedOnCompletion = NO;
    [self.layer addAnimation:shadowGrowAnim forKey:SHADOW_GROW_KEY];
    [self.layer setShadowRadius:SHADOW_RADIUS * SHADOW_SCALE_FACTOR];
}

- (void)_shadowShrink
{
    CABasicAnimation *shadowShrinkAnim = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    shadowShrinkAnim.delegate = self;
    [shadowShrinkAnim setFromValue:[NSNumber numberWithFloat:SHADOW_RADIUS * SHADOW_SCALE_FACTOR]];
    [shadowShrinkAnim setToValue:[NSNumber numberWithFloat:SHADOW_RADIUS]];
    [shadowShrinkAnim setDuration:RETURN_SPEED];

    shadowShrinkAnim.removedOnCompletion = NO;
    [self.layer addAnimation:shadowShrinkAnim forKey:SHADOW_SHRINK_KEY];
    [self.layer setShadowRadius:SHADOW_RADIUS];
}

- (void)_handleExit
{
    self.displayed = NO;
    // center should be at post-exit point
    if (self.center.y > [[UIScreen mainScreen] bounds].size.height/2) {
        // swiped downwards
        [self.delegate didDismissPaste:self.entity];
    } else {
        // swiped upwards
        [self.delegate shouldStorePaste:self.entity];
    }
}

- (void)_gotDatPan:(UIPanGestureRecognizer *)pgr
{
    FLPasteView *pasteView = (FLPasteView *)pgr.view;
    if (pgr.state == UIGestureRecognizerStateChanged) {
        CGPoint center = pasteView.center;
        CGPoint trans = [pgr translationInView:pasteView];
        center = CGPointMake(center.x, center.y + trans.y);
        pasteView.center = center;

        [pgr setTranslation:CGPointZero inView:pasteView];
        pasteView.lastVelocity = [pgr velocityInView:pasteView];
        [self.delegate pasteViewMoved:pasteView.center.y - self.originalCenter.y];
    } else if (pgr.state == UIGestureRecognizerStateEnded) {
        [pasteView _endAnimation];
    }
}

# pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // the animation itself won't set the shadow value; set appropriately here
    if (anim == [self.layer animationForKey:SHADOW_GROW_KEY]) {
        [self.layer removeAnimationForKey:SHADOW_GROW_KEY];
    } else if (anim == [self.layer animationForKey:SHADOW_SHRINK_KEY]) {
        [self.layer removeAnimationForKey:SHADOW_SHRINK_KEY];
    }
}

@end
