//
//  FLEntityCell.m
//  Flick
//
//  Created by Matt Nichols on 1/20/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLEntityCell.h"
#import "FLDropboxHelper.h"

#define HIGHLIGHT_COLOR [UIColor colorWithRed:0.627 green:0.78 blue:0.91 alpha:1.0]
#define HIGHLIGHT_FADE_IN 0.0f
#define HIGHLIGHT_FADE_OUT 0.4f
#define CELL_FONT [UIFont systemFontOfSize:18.0f]
#define CELL_PADDING_TOP 11.0f
#define CELL_PADDING_LEFT 15.0f
#define MAX_CONTENT_HEIGHT 120.0f
#define IMAGE_CORNER_RADIUS 5.0f

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

        [self _setLoading];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.imageView sizeToFit];
    self.imageView.frame = CGRectIntersection(CGRectInset(self.bounds, CELL_PADDING_LEFT, CELL_PADDING_TOP), self.imageView.frame);
    self.imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self _setLoading];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:((highlighted) ? HIGHLIGHT_FADE_IN : HIGHLIGHT_FADE_OUT) animations:^{
        self.backgroundColor = (highlighted) ? HIGHLIGHT_COLOR : [UIColor clearColor];
    }];
}

- (void)loadEntity:(DBFileInfo *)info width:(CGFloat)width completion:(void (^)(CGFloat height))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.entity = [[FLDropboxHelper sharedHelper] retrieveFile:info];
        CGFloat height = [self _heightForEntity:self.entity width:width];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.entity.type == PhotoEntity) {
                self.imageView.image = self.entity.image;
            } else {
                self.textLabel.text = self.entity.text;
            }
            self.loading = NO;
            [self setNeedsLayout];
            completionBlock(height);
        });
    });
}

- (void)_setLoading
{
    self.imageView.image = nil;
    self.textLabel.text = nil;
    self.loading = YES;
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
    return baseHeight + CELL_PADDING_TOP * 2;
}

@end
