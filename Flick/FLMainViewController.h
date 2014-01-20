//
//  FLMainViewController.h
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLPasteView.h"
#import "FLHistoryDataSource.h"

@interface FLMainViewController : UIViewController <FLPasteViewDelegate, FLHistoryActionsDelegate>

@end
