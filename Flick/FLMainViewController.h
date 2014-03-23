//
//  FLMainViewController.h
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLHistoryDataSource.h"
#import "FLPasteView.h"

@interface FLMainViewController : UIViewController <FLPasteViewDelegate, FLHistoryActionsDelegate, UINavigationControllerDelegate>

@end
