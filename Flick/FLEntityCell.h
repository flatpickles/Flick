//
//  FLEntityCell.h
//  Flick
//
//  Created by Matt Nichols on 1/20/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLEntity.h"

@interface FLEntityCell : UITableViewCell

@property (nonatomic) FLEntity *entity;

+ (CGFloat)heightForEntity:(FLEntity *)entity width:(CGFloat)width;

@end
