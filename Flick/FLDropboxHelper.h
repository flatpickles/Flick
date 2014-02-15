//
//  FLDropboxHelper.h
//  Flick
//
//  Created by Matt Nichols on 11/29/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <Dropbox/Dropbox.h>
#import <Foundation/Foundation.h>
#import "FLEntity.h"
#import "FLGuideView.h"
#import "FLHistoryDataSource.h"

@class DBError;

@interface FLDropboxHelper : NSObject

+ (FLDropboxHelper *)sharedHelper;

@property (nonatomic) FLGuideView *guideView;
@property (nonatomic, readonly) NSArray *fileListing;

- (BOOL)isLinked;
- (void)linkIfUnlinked:(UIViewController *)controller completion:(void (^)(BOOL))completionBlock;
- (BOOL)finishLinking:(NSURL *)url;
- (void)handleError:(DBError *)error;

- (BOOL)canStoreObject:(id)object;
- (void)storeEntity:(FLEntity *)entity completion:(void (^)(DBFileInfo *info))completionBlock;
- (FLEntity *)retrieveFile:(DBFileInfo *)fileInfo;
- (BOOL)deleteFile:(DBFileInfo *)fileInfo;
- (void)copyFile:(DBFileInfo *)fileInfo delegate:(id<FLHistoryActionsDelegate>)delegate;
- (void)copyLinkForFile:(DBFileInfo *)fileInfo delegate:(id<FLHistoryActionsDelegate>)delegate;

@end
