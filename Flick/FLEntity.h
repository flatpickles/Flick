//
//  FLEntity.h
//  Flick
//
//  Created by Matt Nichols on 11/29/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TextEntity,
    PhotoEntity
} FLEntityType;

@interface FLEntity : NSObject

@property (nonatomic) FLEntityType type;

- (FLEntity *)initWithObject:(id)object;
- (NSString *)nameForFile;

- (NSString *)text;

@end
