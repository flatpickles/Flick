//
//  FLPasteView.h
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLEntity.h"

@protocol FLPasteViewDelegate <NSObject>

- (void)shouldStorePaste:(FLEntity *)pasteEntity;
- (void)didDismissPaste:(FLEntity *)pasteEntity;
- (void)pasteViewActive;
- (void)pasteViewReset;
- (void)pasteViewMoved:(CGFloat)yOffset;

@end

@interface FLPasteView : UIView

@property (nonatomic) id<FLPasteViewDelegate> delegate;
@property (nonatomic) FLEntity *entity;

- (void)fadeIn:(CGFloat)duration;

@end
