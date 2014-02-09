//
//  FLGuideView.h
//  Flick
//
//  Created by Matt Nichols on 1/19/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FLGuideDisplayTypeBoth,
    FLGuideDisplayTypeTop,
    FLGuideDisplayTypeBottom
} FLGuideDisplayType;

@interface FLGuideView : UIView

- (void)fadeRelativeToPasteOffset:(CGFloat)yOffset;
- (void)show:(FLGuideDisplayType)displayType;
- (void)hide:(FLGuideDisplayType)displayType;
- (void)show:(FLGuideDisplayType)displayType delay:(CGFloat)delay completion:(void (^)(BOOL finished))completion;
- (void)hide:(FLGuideDisplayType)displayType delay:(CGFloat)delay completion:(void (^)(BOOL finished))completion;
- (void)displayMessage:(NSString *)message;
- (void)displayError:(NSString *)message;

@end
