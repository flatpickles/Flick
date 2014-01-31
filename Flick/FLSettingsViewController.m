//
//  FLSettingsViewController.m
//  Flick
//
//  Created by Matt Nichols on 1/23/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLSettingsViewController.h"

#define SETTINGS_TITLE @"Settings"
#define CELL_PADDING_TOP 11.0f
#define CELL_PADDING_LEFT 15.0f
#define SWITCH_CELL_HEIGHT 50.0f

@interface FLSettingsViewController ()

@property (nonatomic) NSArray *sections;

@end

@implementation FLSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = SETTINGS_TITLE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)sections
{
    if (!_sections) {
        NSMutableArray *sections = [[NSMutableArray alloc] init];

        // copy link on upload
        [sections addObject:[self _infoHeaderCellContents]];
        [sections addObject:[self _cellContentsForTitle:@"Copy link on file upload"]];
        [sections addObject:[self _cellContentsForTitle:@"Shake to use last photo"]];
        
        _sections = [sections mutableCopy];
    }
    return _sections;
}

- (UIView *)_infoHeaderCellContents
{
    NSString *copy = @"You can single tap to copy, long press to copy a shortened Dropbox link, and double tap to view a photo or open a link. Further optional functionality:";
    CGFloat width = self.tableView.frame.size.width;
    UIFont *infoFont = [UIFont systemFontOfSize:15.0f];
    CGRect textSize = [copy boundingRectWithSize:CGSizeMake(width - CELL_PADDING_LEFT * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:infoFont} context:nil];

    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, textSize.size.height + 2 * CELL_PADDING_TOP)];
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectOffset(textSize, CELL_PADDING_LEFT, CELL_PADDING_TOP)];
    infoLabel.text = copy;
    infoLabel.font = infoFont;
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel.numberOfLines = 0;
    [infoView addSubview:infoLabel];

    return infoView;
}

- (UIView *)_cellContentsForTitle:(NSString *)title
{
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, SWITCH_CELL_HEIGHT)];
    UILabel *cellLabel =  [[UILabel alloc] initWithFrame:CGRectZero];
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];

    CGRect labelRect, switchRect;
    CGRectDivide(cellView.frame, &labelRect, &switchRect, CGRectGetMaxX(cellView.frame) - switchView.frame.size.width - 2 * CELL_PADDING_LEFT, CGRectMinXEdge);

    cellLabel.frame = CGRectInset(labelRect, CELL_PADDING_LEFT, CELL_PADDING_TOP);
    cellLabel.text = title;
    [cellView addSubview:cellLabel];

    switchView.frame = CGRectInset(switchRect, CELL_PADDING_LEFT, CELL_PADDING_TOP);
    switchView.contentMode = UIViewContentModeRight;
    [cellView addSubview:switchView];

    return cellView;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // not reusing cells, since we've only got a few static ones
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    [cell.contentView addSubview:[self.sections objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections count];
}

# pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *sectionView = [self.sections objectAtIndex:indexPath.row];
    return sectionView.frame.size.height;
}

@end
