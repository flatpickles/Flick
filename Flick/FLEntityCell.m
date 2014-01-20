//
//  FLEntityCell.m
//  Flick
//
//  Created by Matt Nichols on 1/20/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLEntityCell.h"

#define HIGHLIGHT_COLOR [UIColor colorWithRed:0.455 green:0.702 blue:0.91 alpha:1.0]
#define HIGHLIGHT_FADE_IN 0.0f
#define HIGHLIGHT_FADE_OUT 0.4f


@implementation FLEntityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setEntity:(FLEntity *)entity
{
    _entity = entity;
    if (entity.type == PhotoEntity) {
        // todo: this
    } else {
        self.textLabel.text = entity.text;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    // todo: configure here
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:((highlighted) ? HIGHLIGHT_FADE_IN : HIGHLIGHT_FADE_OUT) animations:^{
        self.backgroundColor = (highlighted) ? HIGHLIGHT_COLOR : [UIColor clearColor];
    }];
}

@end
