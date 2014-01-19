//
//  FLDropboxHelper.h
//  Flick
//
//  Created by Matt Nichols on 11/29/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBError;

@interface FLDropboxHelper : NSObject

+ (FLDropboxHelper *)sharedHelper;

- (void)linkIfUnlinked:(UIViewController *)controller completion:(void (^)(BOOL))completionBlock;
- (BOOL)finishLinking:(NSURL *)url;

- (BOOL)isStored:(id)object;
- (NSArray *)storedObjects;
- (BOOL)storeObject:(id)object;

-(void)handleError:(DBError *)error;

@end
