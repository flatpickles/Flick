//
//  FLDropboxHelper.m
//  Flick
//
//  Created by Matt Nichols on 11/29/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import <Dropbox/Dropbox.h>
#import "FLDropboxHelper.h"
#import "FLEntity.h"

#define APP_KEY @"ynm3dgog8z5rr7t"
#define APP_SECRET @"mt17g6d4cv44vif"

@interface FLDropboxHelper()

@property (nonatomic) NSArray *fileListing;
@property (nonatomic, strong) void (^linkCompletion)(BOOL);

@end

@implementation FLDropboxHelper

+ (FLDropboxHelper *)sharedHelper
{
    static FLDropboxHelper *helper = nil;
    if (!helper) {
        helper = [[FLDropboxHelper alloc] init];
        // setup dropbox manager
        DBAccountManager *mgr = [[DBAccountManager alloc] initWithAppKey:APP_KEY secret:APP_SECRET];
        [DBAccountManager setSharedManager:mgr];
    }
    return helper;
}

#pragma mark - Linking

- (void)linkIfUnlinked:(UIViewController *)controller completion:(void (^)(BOOL))completionBlock
{
    DBAccountManager *manager = [DBAccountManager sharedManager];
    if (![manager linkedAccount]) {
        [manager linkFromController:controller];
        _linkCompletion = completionBlock;
    } else if (![DBFilesystem sharedFilesystem]) {
        [DBFilesystem setSharedFilesystem:[[DBFilesystem alloc] initWithAccount:[manager linkedAccount]]];
        completionBlock(YES);
    }
}

- (BOOL)finishLinking:(NSURL *)url
{
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        // setup dropbox filesystem
        DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
        if (!filesystem) {
            filesystem = [[DBFilesystem alloc] initWithAccount:account];
            [DBFilesystem setSharedFilesystem:filesystem];
        }
    }

    BOOL success = !!account;
    _linkCompletion(success);
    return success;
}

#pragma mark - Storage management

- (BOOL)isStored:(id)object
{
    FLEntity *entity = [[FLEntity alloc] initWithObject:object];
    DBPath *path = [[DBPath root] childPath:[entity nameForFile]];
    return [self _isStored:path];
}

- (BOOL)_isStored:(DBPath *)path
{
    DBError *error = nil;
    if (![[DBFilesystem sharedFilesystem] fileInfoForPath:path error:&error]) {
        if (error && error.code != DBErrorParamsNotFound) {
            [self handleError:error];
        } else {
            return NO;
        }
    }
    return YES;
}

- (NSArray *)storedObjects
{
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[self.fileListing count]];
    for (DBFileInfo *info in self.fileListing) {
        DBError *error = nil;
        DBFile *file = [[DBFilesystem sharedFilesystem] openFile:info.path error:&error];
        NSData *fileData = [file readData:&error];

        if (error) {
            [self handleError:error];
        } else {
            UIImage *imgCandidate = [UIImage imageWithData:fileData];
            [objects addObject:[[FLEntity alloc] initWithObject:(imgCandidate) ? imgCandidate : [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding]]];
        }
        [file close];
    }

    return [objects copy];
}

- (BOOL)storeObject:(id)object
{
    FLEntity *entity = [[FLEntity alloc] initWithObject:object];
    DBPath *path = [[DBPath root] childPath:[entity nameForFile]];
    if (![self _isStored:path]) {
        DBError *error = nil;
        DBFile *file = [[DBFilesystem sharedFilesystem] createFile:path error:&error];
        NSData *dataToWrite;
        if (entity.type == TextEntity) {
            dataToWrite = [object dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            dataToWrite = UIImagePNGRepresentation(object);
        }
        [file writeData:dataToWrite error:&error];
        [file close];
        return !error;
    }
    return NO;
}

#pragma mark - Helpers

- (void)handleError:(DBError *)error
{
    // todo: something better?
    NSLog(@"Dropbox error: %@", [error description]);
}

- (NSArray *)fileListing
{
    DBFilesystem *fs = [DBFilesystem sharedFilesystem];
    if (!_fileListing && fs) {
        DBError *error = nil;
        _fileListing = [fs listFolder:[DBPath root] error:&error];
        if (error) {
            [self handleError:error];
            _fileListing = nil;
        }
    }
    return _fileListing;
}

@end
