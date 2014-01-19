//
//  FLHistoryTableViewController.h
//  Flick
//
//  Created by Matt Nichols on 11/24/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLHistoryTableViewController : UITableViewController

@property (nonatomic) NSArray *backingData;
@property (nonatomic) BOOL titleHidden;

- (void)fadeToOpacity:(CGFloat)opacity withDuration:(NSTimeInterval)duration;

@end
