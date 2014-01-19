//
//  FLHistoryTableViewController.m
//  Flick
//
//  Created by Matt Nichols on 11/24/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

#import "FLHistoryTableViewController.h"
#import "FLEntity.h"

#define TITLE_FADE_IN 0.3f
#define TITLE_FADE_OUT 0.1f
#define HIDDEN_TITLE_OPACITY 0.15f

#define CELL_IDENTIFIER @"FLCell"

@interface FLHistoryTableViewController ()

@property (nonatomic) UILabel *navigationLabel;

@end

@implementation FLHistoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // setup a replacement navigation label so we can control opacity directly
    self.navigationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.navigationLabel.backgroundColor = [UIColor clearColor];
    self.navigationLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.navigationLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationLabel.textColor = [UIColor blackColor];
    self.navigationLabel.text = @"Your Previous Pastes";
    self.navigationItem.titleView = self.navigationLabel;
    [self.navigationLabel sizeToFit];
}

- (void)setTitleHidden:(BOOL)titleHidden
{
    _titleHidden = titleHidden;
    if (titleHidden) {
        [UIView animateWithDuration:TITLE_FADE_OUT animations:^{
            self.navigationLabel.layer.opacity = HIDDEN_TITLE_OPACITY;
        }];
    } else {
        [UIView animateWithDuration:TITLE_FADE_IN animations:^{
            self.navigationLabel.layer.opacity = 1.0f;
        }];
    }
}

- (void)fadeToOpacity:(CGFloat)opacity withDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.view.layer.opacity = opacity;
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.backingData ? [self.backingData count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }

    FLEntity *displayedObject = [self.backingData objectAtIndex:indexPath.row];
    if (displayedObject.type == TextEntity) {
        // present a string
        cell.textLabel.text = displayedObject.text;
    } else {
        // todo: present something else
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


@end
