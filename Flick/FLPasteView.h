//
//  FLPasteView.h
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FLPasteViewDelegate <NSObject>

- (BOOL)shouldStorePaste:(id)pasteObject;
- (void)didDismissPaste:(id)pasteObject;

@end

@interface FLPasteView : UIView

@property (nonatomic) id<FLPasteViewDelegate> delegate;
@property (nonatomic) CGPoint lastVelocity;
@property (nonatomic) NSString *text;

- (void)resetWithAnimations:(BOOL)animate;
- (void)endAnimation;

@end
