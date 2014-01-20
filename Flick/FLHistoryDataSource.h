//
//  FLHistoryDataSource.h
//  Flick
//
//  Created by Matt Nichols on 1/19/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLEntity.h"

@protocol FLHistoryActionsDelegate <NSObject>

- (void)didCopyEntity:(FLEntity *)entity;
- (void)didCopyLinkForEntity:(FLEntity *)entity;

@end

@interface FLHistoryDataSource : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSMutableArray *fileInfoArray;
@property (nonatomic) id<FLHistoryActionsDelegate> delegate;

@end
