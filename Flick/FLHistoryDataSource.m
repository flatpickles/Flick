//
//  FLHistoryDataSource.m
//  Flick
//
//  Created by Matt Nichols on 1/19/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import <Dropbox/Dropbox.h>
#import "FLHistoryDataSource.h"
#import "FLDropboxHelper.h"
#import "FLEntityCell.h"

#define CELL_IDENTIFIER @"FLCell"

@implementation FLHistoryDataSource

- (void)handleLongPress:(NSIndexPath *)indexPath
{
    // copy the shortened DB link to the file at this index path
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DBFileInfo *info = [self.fileInfoArray objectAtIndex:indexPath.row];
        NSString *path = [[FLDropboxHelper sharedHelper] linkForFile:info];
        [UIPasteboard generalPasteboard].URL = [NSURL URLWithString:path];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fileInfoArray ? [self.fileInfoArray count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLEntityCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[FLEntityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }

    DBFileInfo *info = [self.fileInfoArray objectAtIndex:indexPath.row];
    cell.entity = [[FLDropboxHelper sharedHelper] retrieveFile:info];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // enable deletion
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[FLDropboxHelper sharedHelper] deleteFile:[self.fileInfoArray objectAtIndex:indexPath.row]];
        [self.fileInfoArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

# pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // copy the entity at this index to clipboard
    DBFileInfo *info = [self.fileInfoArray objectAtIndex:indexPath.row];
    FLEntity *entity = [[FLDropboxHelper sharedHelper] retrieveFile:info];
    if (entity.type == PhotoEntity) {
        [UIPasteboard generalPasteboard].image = entity.image;
    } else {
        [UIPasteboard generalPasteboard].string = entity.text;
    }
    [self.delegate didCopyEntity:entity];
}

@end
