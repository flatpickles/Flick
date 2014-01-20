//
//  FLHistoryDataSource.h
//  Flick
//
//  Created by Matt Nichols on 1/19/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLHistoryDataSource : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSMutableArray *fileInfoArray;

@end
