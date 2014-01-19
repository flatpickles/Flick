//
//  FLEntity.m
//  Flick
//
//  Created by Matt Nichols on 11/29/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "FLEntity.h"

#define HASH_LENGTH 12

@interface FLEntity ()

@property (nonatomic) id backingObject;

@end

@implementation FLEntity

- (FLEntity *)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        self.backingObject = object;
        if ([object isKindOfClass:[UIImage class]]) {
            self.type = PhotoEntity;
        } else if ([object isKindOfClass:[NSString class]]) {
            self.type = TextEntity;
        } else {
            NSAssert(NO, @"Entity initialized with unrecognized object type.");
        }
    }
    return self;
}

- (NSString *)nameForFile
{
    NSString *base = [self _hashStr];
    return [NSString stringWithFormat:@"%@%@", base, (self.type == PhotoEntity) ? @".png" : @".txt"];
}

- (NSString *)text
{
    if (self.type == TextEntity) {
        return self.backingObject;
    } else {
        return nil;
    }
}

- (NSString *)_hashStr
{
    NSString *someStr;
    switch (self.type) {
        case PhotoEntity:
        {
            UIImage *img = self.backingObject;
            NSData *photoData = UIImagePNGRepresentation(img);
            someStr = [NSString stringWithFormat:@"img:\"data:image/png;base64,%@\"", [photoData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength]];
            break;
        }
        case TextEntity:
        {
            someStr = self.backingObject;
            break;
        }
    }
    const char *cStr = [someStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    NSString *hash = [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    return [hash substringToIndex:HASH_LENGTH];
}

@end
