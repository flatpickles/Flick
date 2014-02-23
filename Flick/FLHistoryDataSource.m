//
//  FLHistoryDataSource.m
//  Flick
//
//  Created by Matt Nichols on 1/19/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLDetailViewController.h"
#import "FLDropboxHelper.h"
#import "FLEntityCell.h"
#import "FLHistoryDataSource.h"

#define CELL_IDENTIFIER @"FLCell"
#define LOADING_FADE_IN_DURATION 0.25f

@interface FLHistoryDataSource ()

// maps DBFileInfo -> Cell height, also used as a record of which cells have loaded
@property (atomic) NSMutableDictionary *loadedHeights;

@end

@implementation FLHistoryDataSource

- (id)init
{
    self = [super init];
    if (self) {
        self.loadedHeights = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)handleLongPress:(NSIndexPath *)indexPath
{
    // copy the shortened DB link to the file at this index path
    DBFileInfo *info = [self.fileInfoArray objectAtIndex:indexPath.row];
    if ([self.loadedHeights objectForKey:info]) {
        [[FLDropboxHelper sharedHelper] copyLinkForFile:info delegate:self.delegate];
    }
}

- (void)handleRightSwipe:(NSIndexPath *)indexPath navController:(UINavigationController *)nav
{
    DBFileInfo *info = [self.fileInfoArray objectAtIndex:indexPath.row];
    if ([self.loadedHeights objectForKey:info]) {
        FLDetailViewController *detailVC = [[FLDetailViewController alloc] initWithEntity:[[FLDropboxHelper sharedHelper] retrieveFile:info]];
        [UIView animateWithDuration:FLIP_DURATION animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [nav pushViewController:detailVC animated:NO];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:nav.view cache:NO];
        }];
    }
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
    if (cell.currentInfo == info && !cell.loading) {
        // if we've loaded this already, let's just use it!
        return cell;
    }

    NSNumber *currentHeight = [self.loadedHeights objectForKey:info];
    [cell loadEntity:info width:self.tableView.frame.size.width showSpinner:!currentHeight completion:^(CGFloat height) {
        [self.loadedHeights setObject:[NSNumber numberWithFloat:height] forKey:info];
        if (!currentHeight) {
            // fade out the spinner
            [UIView animateWithDuration:LOADING_FADE_IN_DURATION animations:^{
                cell.loadingView.layer.opacity = 0.0f;
            } completion:^(BOOL finished) {
                [cell.loadingView stopAnimating];
            }];
            cell.textLabel.layer.opacity = 0.0f;
            cell.imageView.layer.opacity = 0.0f;
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [UIView animateWithDuration:LOADING_FADE_IN_DURATION animations:^{
                    cell.textLabel.layer.opacity = 1.0f;
                    cell.imageView.layer.opacity = 1.0f;
                } completion:nil];
            }];
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
            [CATransaction commit];
        }
        [cell setNeedsLayout];
    }];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // enable deletion
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBFileInfo *info = [self.fileInfoArray objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete && [self.loadedHeights objectForKey:info]) {
        BOOL success = [[FLDropboxHelper sharedHelper] deleteFile:info];
        if (success) {
            [UIView animateWithDuration:0.2f animations:^{
                // fade out to hide Delete button
                // todo: is this the best solution?
                [tableView cellForRowAtIndexPath:indexPath].alpha = 0.0;
            }];
            [self.loadedHeights removeObjectForKey:info];
            [self.fileInfoArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

# pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // copy the entity at this index to clipboard
    DBFileInfo *info = [self.fileInfoArray objectAtIndex:indexPath.row];
    if ([self.loadedHeights objectForKey:info]) {
        [[FLDropboxHelper sharedHelper] copyFile:info delegate:self.delegate];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBFileInfo *info = [self.fileInfoArray objectAtIndex:indexPath.row];
    NSNumber *height = [self.loadedHeights objectForKey:info];
    if (height) {
        return height.floatValue;
    } else {
        return CELL_LOADING_HEIGHT;
    }
}

@end
