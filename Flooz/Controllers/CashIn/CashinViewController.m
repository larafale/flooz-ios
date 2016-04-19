//
//  CashinViewController.m
//  Flooz
//
//  Created by Olive on 4/14/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "CashinViewController.h"
#import "CashinCreditCardViewController.h"
#import "CashinAudiotelViewController.h"

@interface CashinViewController () {
    NSArray *methods;
    UIView *navHeaderView;
}

@end

@implementation CashinViewController
- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    if (!self.title || [self.title isBlank])
    //        self.title = @"Charger son compte";
    
    [self createHeader];
    
    methods = @[@{
                    @"title":@"Carte bancaire",
                    @"subtitle":@"Blablabla",
                    @"img":@"cashin_cb",
                    @"controller": [CashinCreditCardViewController new]
                    },
                @{
                    @"title":@"Audiotel",
                    @"subtitle":@"Flaflaflafla",
                    @"img":@"cashin_phone",
                    @"controller": [CashinAudiotelViewController new]
                    }];
    
    _tableView = [FLTableView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setScrollsToTop:YES];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_mainBody addSubview:_tableView];
    
    // Padding pour que le dernier element au dessus du +
    _tableView.tableFooterView = [UIView new];
}

- (void)createHeader {
    if (!navHeaderView) {
        navHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPTabBarHeight())];
        
        NSString *headerString = [NSString stringWithFormat:@"Votre solde : %@", [FLHelper formatedAmount:[Flooz sharedInstance].currentUser.amount withCurrency:YES withSymbol:NO]];
        
        UILabel *headerMoment = [[UILabel alloc] initWithText:headerString textColor:[UIColor customBlue] font:[UIFont customTitleLight:15] textAlignment:NSTextAlignmentLeft numberOfLines:1];
        headerMoment.tag = 42;
        
        CGFloat headerWidth = CGRectGetWidth(headerMoment.frame);
        
        CGRectSetWidth(navHeaderView.frame, headerWidth);
        
        CGFloat midHeight = PPTabBarHeight() / 2;
        
        CGRectSetXY(headerMoment.frame, 0, midHeight - CGRectGetHeight(headerMoment.frame) / 2 - 2);
        
        [navHeaderView addSubview:headerMoment];
        self.navigationItem.titleView = navHeaderView;
    } else {
        NSString *headerString = [NSString stringWithFormat:@"Votre solde : %@", [FLHelper formatedAmount:[Flooz sharedInstance].currentUser.amount withCurrency:YES withSymbol:NO]];
        
        UILabel *headerMoment = [navHeaderView viewWithTag:42];
        headerMoment.text = headerString;
        
        CGFloat headerWidth = CGRectGetWidth(headerMoment.frame);
        
        CGRectSetWidth(navHeaderView.frame, headerWidth);
        
        CGFloat midHeight = PPTabBarHeight() / 2;
        
        CGRectSetXY(headerMoment.frame, 0, midHeight - CGRectGetHeight(headerMoment.frame) / 2 - 2);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return methods.count;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CashinCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor customBackgroundHeader];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self fillCell:cell.contentView data:methods[indexPath.row]];
    
    return cell;
}

- (void)fillCell:(UIView *)contentView data:(NSDictionary *)buttonData {
    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(10, [self tableView:_tableView heightForRowAtIndexPath:[NSIndexPath new]] / 2 - 15, 30, 30)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tintColor = [UIColor customBlue];
    
    imageView.image = [[UIImage imageNamed:buttonData[@"img"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, 10, PPScreenWidth() - CGRectGetMaxX(imageView.frame) - 45, 15)];
    titleLabel.font = [UIFont customContentRegular:15];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = buttonData[@"title"];
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 10. / titleLabel.font.pointSize;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, CGRectGetMaxY(titleLabel.frame), PPScreenWidth() - CGRectGetMaxX(imageView.frame) - 45, 25)];
    subtitleLabel.font = [UIFont customContentRegular:12];
    subtitleLabel.textColor = [UIColor customPlaceholder];
    subtitleLabel.text = buttonData[@"subtitle"];
    subtitleLabel.numberOfLines = 2;
    subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    subtitleLabel.adjustsFontSizeToFitWidth = YES;
    subtitleLabel.minimumScaleFactor = 5. / titleLabel.font.pointSize;
    subtitleLabel.textAlignment = NSTextAlignmentLeft;
    
    CGFloat fontSize = [subtitleLabel.text fontSizeWithFont:subtitleLabel.font constrainedToSize:subtitleLabel.frame.size];
    subtitleLabel.font = [UIFont customContentRegular:fontSize];
    
    UIImageView *nextIcon = [[UIImageView alloc] initWithFrame:CGRectMake(PPScreenWidth() - 25, [self tableView:_tableView heightForRowAtIndexPath:[NSIndexPath new]] / 2 - 10, 20, 20)];
    nextIcon.contentMode = UIViewContentModeScaleAspectFit;
    nextIcon.tintColor = [UIColor customBlue];
    nextIcon.image = [[UIImage imageNamed:@"arrow-right-accessory"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [contentView addSubview:imageView];
    [contentView addSubview:titleLabel];
    [contentView addSubview:subtitleLabel];
    [contentView addSubview:nextIcon];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = methods[indexPath.row];
    
    if (rowData && rowData[@"controller"] && [rowData[@"controller"] isKindOfClass:[BaseViewController class]])
        [self.navigationController pushViewController:rowData[@"controller"] animated:YES];
}

@end
