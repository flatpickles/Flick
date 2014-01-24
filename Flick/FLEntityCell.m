//
//  FLEntityCell.m
//  Flick
//
//  Created by Matt Nichols on 1/20/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLEntityCell.h"

#define HIGHLIGHT_COLOR [UIColor colorWithRed:0.627 green:0.78 blue:0.91 alpha:1.0]
#define HIGHLIGHT_FADE_IN 0.0f
#define HIGHLIGHT_FADE_OUT 0.4f
#define CELL_FONT [UIFont systemFontOfSize:18.0f]
#define CELL_PADDING_TOP 11.0f
#define CELL_PADDING_LEFT 15.0f

@implementation FLEntityCell

+ (CGFloat)heightForEntity:(FLEntity *)entity width:(CGFloat)width
{
    if (entity.type == PhotoEntity) {
        // todo: this
        return 50.0f;
    } else {
        CGRect textSize = [entity.text boundingRectWithSize:CGSizeMake(width - CELL_PADDING_LEFT * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:CELL_FONT} context:nil];
        return textSize.size.height + CELL_PADDING_TOP * 2;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = CELL_FONT;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
    }
    return self;
}

- (void)setEntity:(FLEntity *)entity
{
    _entity = entity;
    if (entity.type == PhotoEntity) {
        // todo: this
        self.textLabel.text = @"image support coming soon";
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
