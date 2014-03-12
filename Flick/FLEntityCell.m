//
//  FLEntityCell.m
//  Flick
//
//  Created by Matt Nichols on 1/20/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLDropboxHelper.h"
#import "FLEntityCell.h"

#define CELL_FONT [UIFont systemFontOfSize:18.0f]
#define CELL_MIN_HEIGHT 50.0f
#define CELL_PADDING_LEFT 15.0f
#define CELL_PADDING_TOP 11.0f
#define HIGHLIGHT_COLOR [UIColor colorWithRed:0.627 green:0.78 blue:0.91 alpha:1.0]
#define HIGHLIGHT_FADE_IN 0.0f
#define HIGHLIGHT_FADE_OUT 0.4f
#define IMAGE_CORNER_RADIUS 5.0f
#define MAX_CONTENT_HEIGHT 120.0f
#define SPINNER_SIZE 30.0f

@interface FLEntityCell ()

@property (atomic) FLEntity *entity;
@property (atomic) BOOL loading;

@end

@implementation FLEntityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.textLabel.font = CELL_FONT;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textLabel.numberOfLines = 0;

        self.imageView.clipsToBounds = YES;
        self.imageView.layer.cornerRadius = IMAGE_CORNER_RADIUS;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;

        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingView.hidesWhenStopped = YES;
        [self addSubview:self.loadingView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.loadingView.frame = CGRectMake(self.bounds.size.width/2 - SPINNER_SIZE/2, CELL_LOADING_HEIGHT/2 - SPINNER_SIZE/2, SPINNER_SIZE, SPINNER_SIZE);
    self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

    [self.imageView sizeToFit];
    self.imageView.frame = CGRectIntersection(CGRectInset(self.bounds, CELL_PADDING_LEFT, CELL_PADDING_TOP), self.imageView.frame);
    self.imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:((highlighted) ? HIGHLIGHT_FADE_IN : HIGHLIGHT_FADE_OUT) animations:^{
        self.backgroundColor = (highlighted) ? HIGHLIGHT_COLOR : [UIColor clearColor];
    }];
}

- (void)loadEntity:(DBFileInfo *)info width:(CGFloat)width showSpinner:(BOOL)showSpinner completion:(void (^)(CGFloat height))completionBlock
{
    [self _setLoading:showSpinner];
    self.currentInfo = info;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FLEntity *retrievedEntity = [[FLDropboxHelper sharedHelper] retrieveFile:info];
        if (self.currentInfo == info && self.loading) {
            self.loading = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.entity = retrievedEntity;
                CGFloat height = [self _heightForEntity:self.entity width:width];
                if (self.entity.type == PhotoEntity) {
                    self.imageView.image = self.entity.image;
                } else {
                    self.textLabel.text = self.entity.text;
                }
                completionBlock(height);
            });
        }
    });
}

- (void)_setLoading:(BOOL)showSpinner
{
    self.imageView.image = nil;
    self.textLabel.text = nil;
    self.loading = YES;
    if (showSpinner) {
        self.loadingView.layer.opacity = 1.0f;
        [self.loadingView startAnimating];
        [self setNeedsLayout];
    }
}

- (CGFloat)_heightForEntity:(FLEntity *)entity width:(CGFloat)width
{
    CGFloat baseHeight;
    if (entity.type == PhotoEntity) {
        baseHeight = MIN(entity.image.size.height, MAX_CONTENT_HEIGHT);
    } else {
        CGRect textSize = [entity.text boundingRectWithSize:CGSizeMake(width - CELL_PADDING_LEFT * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CELL_FONT} context:nil];
        baseHeight = MIN(textSize.size.height, MAX_CONTENT_HEIGHT);
    }
    return MAX(CELL_MIN_HEIGHT, baseHeight + CELL_PADDING_TOP * 2);
}

@end
