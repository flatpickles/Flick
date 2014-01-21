//
//  FLHistoryTableViewController.h
//  Flick
//
//  Created by Matt Nichols on 11/24/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLHistoryDataSource.h"

@interface FLHistoryTableViewController : UITableViewController

@property (nonatomic) FLHistoryDataSource *dataSource;

- (void)hideTitle:(BOOL)hidden animate:(BOOL)animate;
- (void)setOpacity:(CGFloat)opacity withDuration:(NSTimeInterval)duration;

@end
