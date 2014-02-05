//
//  FLDetailViewController.h
//  Flick
//
//  Created by Matt Nichols on 2/3/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLEntity.h"

#define FLIP_DURATION 0.4f

@interface FLDetailViewController : UIViewController

- (id)initWithEntity:(FLEntity *)entity;

@end
