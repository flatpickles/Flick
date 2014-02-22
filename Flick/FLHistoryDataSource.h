//
//  FLHistoryDataSource.h
//  Flick
//
//  Created by Matt Nichols on 1/19/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import <Dropbox/Dropbox.h>
#import <Foundation/Foundation.h>
#import "FLEntity.h"

@protocol FLHistoryActionsDelegate <NSObject>

- (void)didCopyEntity:(FLEntity *)entity;
- (void)didCopyLinkForFile:(DBFileInfo *)entity;

@end

@interface FLHistoryDataSource : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSMutableArray *fileInfoArray;
@property (nonatomic, weak) id<FLHistoryActionsDelegate> delegate;
@property (atomic) UITableView *tableView;

- (void)handleLongPress:(NSIndexPath *)indexPath;
- (void)handleRightSwipe:(NSIndexPath *)indexPath navController:(UINavigationController *)nav;

@end
