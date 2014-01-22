//
//  FLDropboxHelper.h
//  Flick
//
//  Created by Matt Nichols on 11/29/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>
#import "FLEntity.h"

@class DBError;

@interface FLDropboxHelper : NSObject

+ (FLDropboxHelper *)sharedHelper;

@property (nonatomic, readonly) NSArray *fileListing;

- (void)linkIfUnlinked:(UIViewController *)controller completion:(void (^)(BOOL))completionBlock;
- (BOOL)finishLinking:(NSURL *)url;
- (void)handleError:(DBError *)error;

- (BOOL)canStoreObject:(id)object;
- (void)storeObject:(id)object completion:(void (^)(DBFileInfo *info))completionBlock;
- (FLEntity *)retrieveFile:(DBFileInfo *)fileInfo;
- (BOOL)deleteFile:(DBFileInfo *)fileInfo;
- (NSString *)linkForFile:(DBFileInfo *)fileInfo;

@end
