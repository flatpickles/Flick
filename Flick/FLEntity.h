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
// todo: add URL?

@interface FLEntity : NSObject

@property (nonatomic) FLEntityType type;

- (FLEntity *)initWithObject:(id)object;
- (NSString *)nameForFile;
- (BOOL)isEqualToEntity:(FLEntity *)entity;

- (NSString *)text;
- (UIImage *)image;

@end
