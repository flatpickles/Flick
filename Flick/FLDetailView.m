//
//  FLDetailView.m
//  Flick
//
//  Created by Matt Nichols on 2/4/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLDetailView.h"

#define TEXT_EDGE_INSETS 11.0f
#define TEXT_FONT_SIZE 18.0f

@interface FLDetailView ()

@property (nonatomic) UITextView *textView;
@property (nonatomic) UIScrollView *imageScrollView;
@property (nonatomic) UIImageView *imageView;

@end

@implementation FLDetailView

- (void)layoutSubviews
{
    // reset everything
    [self.textView removeFromSuperview];
    [self.imageScrollView removeFromSuperview];
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(TEXT_EDGE_INSETS, 20.0f, self.frame.size.width - 2 * TEXT_EDGE_INSETS, self.frame.size.height - 20.0f - 2 * TEXT_EDGE_INSETS)];
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];

    if (self.entity.type == TextEntity) {
        // layout a scrollable textview
        self.backgroundColor = [UIColor whiteColor];
        self.textView.text = self.entity.text;
        self.textView.editable = NO;
        self.textView.contentInset = UIEdgeInsetsZero;
        self.textView.scrollEnabled = YES;
        self.textView.scrollsToTop = YES;
        self.textView.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
        [self addSubview:self.textView];
    } else if (self.entity.type == PhotoEntity) {
        // layout a zoomable scroll view for the photo
        self.backgroundColor = [UIColor blackColor];
        self.imageScrollView.delegate = self;
        self.imageScrollView.minimumZoomScale = 1.0f;
        self.imageScrollView.maximumZoomScale = 3.0f;
        self.imageScrollView.contentSize = self.imageView.frame.size;

        self.imageView = [[UIImageView alloc] initWithFrame:self.imageScrollView.bounds];
        self.imageView.image = self.entity.image;
        BOOL photoTooSmall = self.entity.image.size.width < self.imageView.frame.size.width || self.entity.image.size.height < self.imageView.frame.size.height;
        self.imageView.contentMode = (photoTooSmall) ? UIViewContentModeCenter : UIViewContentModeScaleAspectFit;

        [self addSubview:self.imageScrollView];
        [self.imageScrollView addSubview:self.imageView];
    }
}

- (void)setEntity:(FLEntity *)entity
{
    _entity = entity;
    [self setNeedsLayout];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
