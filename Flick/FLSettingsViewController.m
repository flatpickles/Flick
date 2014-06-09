//
//  FLSettingsViewController.m
//  Flick
//
//  Created by Matt Nichols on 1/23/14.
//  Copyright (c) 2014 Matt Nichols. All rights reserved.
//

#import "FLSettingsViewController.h"

#define CELL_PADDING_LEFT 15.0f
#define CELL_PADDING_TOP 11.0f
#define SETTINGS_TITLE @"Settings"
#define SWITCH_CELL_HEIGHT 50.0f

@interface FLSettingsViewController ()

@property (nonatomic) NSArray *sections;
@property (nonatomic) NSArray *controlKeys;

@end

@implementation FLSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.controlKeys = @[COPY_LINK_ON_UPLOAD_KEY, SHAKE_TO_USE_PHOTO_KEY];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = SETTINGS_TITLE;
}

- (NSArray *)sections
{
    if (!_sections) {
        NSMutableArray *sections = [[NSMutableArray alloc] init];

        // copy link on upload
        [sections addObject:[self _switchCellContentsForTitle:@"Copy link on file upload:" key:COPY_LINK_ON_UPLOAD_KEY]];
        [sections addObject:[self _switchCellContentsForTitle:@"Shake to paste last photo:" key:SHAKE_TO_USE_PHOTO_KEY]];
        [sections addObject:[self _qualitySliderCellContents]];
        [sections addObject:[self _infoCellContents]];
        
        _sections = [sections mutableCopy];
    }
    return _sections;
}

- (UIView *)_infoCellContents
{
    NSString *title = @"Hints:";
    NSString *copy = @"From the list of your pasted items, you can tap to copy, long press to copy a short Dropbox link, right swipe to view in fullscreen, and left swipe to delete. A plus button will appear in the top left when you have unsaved content available in your clipboard.";

    CGFloat width = self.tableView.frame.size.width;
    UIFont *infoFont = [UIFont systemFontOfSize:15.0f];
    CGRect textSize = [copy boundingRectWithSize:CGSizeMake(width - CELL_PADDING_LEFT * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:infoFont} context:nil];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectOffset(titleLabel.frame, CELL_PADDING_LEFT, CELL_PADDING_TOP);

    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, textSize.size.height + 2.5f * CELL_PADDING_TOP + titleLabel.frame.size.height)];
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectOffset(textSize, CELL_PADDING_LEFT, CELL_PADDING_TOP * 0.5f + CGRectGetMaxY(titleLabel.frame))];
    infoLabel.text = copy;
    infoLabel.font = infoFont;
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel.numberOfLines = 0;

    [infoView addSubview:titleLabel];
    [infoView addSubview:infoLabel];

    return infoView;
}

- (UIView *)_switchCellContentsForTitle:(NSString *)title key:(NSString *)key
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
    switchView.tag = [self.controlKeys indexOfObject:key];
    switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    [switchView addTarget:self action:@selector(_switchValueSet:) forControlEvents:UIControlEventValueChanged];
    [cellView addSubview:switchView];

    return cellView;
}

- (UIView *)_qualitySliderCellContents
{
    // image quality
    CGFloat height = 30.0f;
    CGFloat width = self.tableView.frame.size.width - 2 * CELL_PADDING_LEFT;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING_LEFT, CELL_PADDING_TOP, width, height)];
    label.text = @"Image upload quality:";

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(CELL_PADDING_LEFT, CGRectGetMaxY(label.frame) + CELL_PADDING_TOP, width, height)];
    slider.continuous = NO;
    slider.minimumValue = 0.0f;
    slider.maximumValue = 1.0f;
    NSNumber *currentQuality = [[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_UPLOAD_QUALITY_KEY];
    slider.value = (currentQuality == nil) ? IMAGE_UPLOAD_QUALITY_DEFAULT : currentQuality.floatValue;
    [slider addTarget:self action:@selector(_sliderValueSet:) forControlEvents:UIControlEventValueChanged];

    UIView *qualityView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, CGRectGetMaxY(slider.frame) + CELL_PADDING_TOP)];
    [qualityView addSubview:label];
    [qualityView addSubview:slider];
    return qualityView;
}

- (void)_switchValueSet:(id)sender
{
    UISwitch *switchView = sender;
    NSString *key = [self.controlKeys objectAtIndex:switchView.tag];
    [[NSUserDefaults standardUserDefaults] setBool:switchView.on forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_sliderValueSet:(id)sender
{
    UISlider *slider = sender;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:slider.value] forKey:IMAGE_UPLOAD_QUALITY_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
