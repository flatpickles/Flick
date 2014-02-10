//
//  FLEntityCell.h
//  Flick
//
//  Created by Matt Nichols on 1/20/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>
#import "FLEntity.h"

#define CELL_LOADING_HEIGHT 60.0f

@interface FLEntityCell : UITableViewCell

@property (atomic, readonly) BOOL loading;
@property (nonatomic) UIActivityIndicatorView *loadingView;

- (void)loadEntity:(DBFileInfo *)info width:(CGFloat)width completion:(void (^)(CGFloat height))completionBlock;

@end
