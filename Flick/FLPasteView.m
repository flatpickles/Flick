//
//  FLPasteView.m
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#define SCALE_FACTOR 1.04f
#define START_SPEED 0.05f
#define RETURN_SPEED 0.25f
#define EXIT_DISTANCE 960.0f
#define SWIPE_VELOCITY_THRESHOLD 2000.0f
#define SHADOW_OPACITY 0.7f
#define SHADOW_RADIUS 3.0f
#define SHADOW_SCALE_FACTOR 2.0f
#define CORNER_RADIUS 5.0f
#define TEXT_INSET 30.0f
#define MORE_TEXT_GRADIENT_START 0.7f

#define SHADOW_GROW_KEY @"ShadowGrow"
#define SHADOW_SHRINK_KEY @"ShadowShrink"

#import <QuartzCore/QuartzCore.h>
#import "FLPasteView.h"

@interface FLPasteView()

@property (nonatomic) CGPoint originalCenter;
@property (nonatomic) NSDate *offsetLastSet;
@property (nonatomic) UILabel *textView;

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

        CALayer *layer = self.layer;
        [layer setShadowColor:[UIColor blackColor].CGColor];
        [layer setShadowOpacity:SHADOW_OPACITY];
        [layer setShadowRadius:SHADOW_RADIUS];
        [layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
        self.layer.cornerRadius = CORNER_RADIUS;

        self.textView = [[UILabel alloc] init];
        self.textView.numberOfLines = 0;
        self.textView.lineBreakMode = NSLineBreakByWordWrapping;
        self.textView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        [self addSubview:self.textView];
        
        UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_gotDatPan:)];
        [self addGestureRecognizer:panner];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:START_SPEED delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformMakeScale(SCALE_FACTOR, SCALE_FACTOR);
    } completion:^(BOOL finished) {
        if (finished) {
            [self.delegate pasteViewActive];
        }
    }];
    [self _shadowGrow];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetWithAnimations:YES];
}

- (void)setText:(NSString *)text
{
    _text = text;
    UILabel *tv = self.textView;
    tv.layer.mask = nil;
    tv.frame = CGRectInset(self.bounds, TEXT_INSET, TEXT_INSET);
    tv.text = text;
    [tv sizeToFit];
    CGFloat maxHeight = self.bounds.size.height - 2 * TEXT_INSET;
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

- (void)resetWithAnimations:(BOOL)animate
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
    [self.delegate pasteViewReset];
}

- (void)endAnimation
{
    CGFloat velocity = sqrt(pow(self.lastVelocity.x, 2.0) + pow(self.lastVelocity.y, 2.0));
    if (velocity < SWIPE_VELOCITY_THRESHOLD) {
        [self resetWithAnimations:YES];
    } else {
        // continue animation in the direction of last swipe, at the right speed
        CGFloat theta = atan2f(self.lastVelocity.y, self.lastVelocity.x);
        CGPoint target = CGPointMake(EXIT_DISTANCE * cosf(theta), EXIT_DISTANCE * sinf(theta));
        NSTimeInterval duration = EXIT_DISTANCE / velocity;

        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.center = CGPointMake(self.center.x + target.x, self.center.y + target.y);
            [self _handleExit];
        } completion:nil];
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
}

- (void)_handleExit
{
    // center should be at post-exit point
    if (self.center.y > [[UIScreen mainScreen] bounds].size.height/2) {
        // swiped downwards
        [self.delegate didDismissPaste:self.textView.text];
    } else {
        // swiped upwards
        [self.delegate shouldStorePaste:self.textView.text];
        // todo: handle non-text clipboard entries, handle result of shouldStorePaste
    }
}

- (void)_gotDatPan:(UIPanGestureRecognizer *)pgr
{
    FLPasteView *pasteView = (FLPasteView *)pgr.view;
    if (pgr.state == UIGestureRecognizerStateChanged) {
        CGPoint center = pasteView.center;
        CGPoint trans = [pgr translationInView:pasteView];
        center = CGPointMake(center.x + trans.x, center.y + trans.y);
        pasteView.center = center;
        [pgr setTranslation:CGPointZero inView:pasteView];
        pasteView.lastVelocity = [pgr velocityInView:pasteView];
        [self.delegate pasteViewMoved:pasteView.center.y - self.originalCenter.y];
    } else if (pgr.state == UIGestureRecognizerStateEnded) {
        [pasteView endAnimation];
    }
}

# pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // the animation itself won't set the shadow value; set appropriately here
    if (anim == [self.layer animationForKey:SHADOW_GROW_KEY]) {
        [self.layer setShadowRadius:SHADOW_RADIUS * SHADOW_SCALE_FACTOR];
        [self.layer removeAnimationForKey:SHADOW_GROW_KEY];
    } else if (anim == [self.layer animationForKey:SHADOW_SHRINK_KEY]) {
        [self.layer setShadowRadius:SHADOW_RADIUS];
        [self.layer removeAnimationForKey:SHADOW_SHRINK_KEY];
    }
}

@end
