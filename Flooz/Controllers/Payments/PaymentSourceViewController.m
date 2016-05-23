//
//  PaymentSourceViewController.m
//  Flooz
//
//  Created by Olive on 18/05/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "PaymentSourceViewController.h"

@interface PaymentSourceViewController () {
    NSArray *methods;
    UIView *headerView;
}

@end

@implementation PaymentSourceViewController

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        if (self.triggerData && self.triggerData[@"items"]) {
            NSMutableArray *items = [NSMutableArray new];
            
            for (NSDictionary *item in self.triggerData[@"items"]) {
                [items addObject:[[FLHomeButton alloc] initWithJSON:item]];
            }
            
            methods = items;
        } else
            methods = [Flooz sharedInstance].currentTexts.paymentSources;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_PAY_SOURCE", nil);
    
    [self createHeader];
    
    _tableView = [FLTableView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setScrollsToTop:YES];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setTableFooterView:[UIView new]];
    [_tableView setTableHeaderView:headerView];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBounces:NO];
    
    [_mainBody addSubview:_tableView];
}

- (void)createHeader {
    if (!headerView) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
        
        UILabel *cashinInfos = [[UILabel alloc] initWithText:NSLocalizedString(@"PAYMENT_INFOS", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleLight:14] textAlignment:NSTextAlignmentCenter numberOfLines:3];
        cashinInfos.adjustsFontSizeToFitWidth = YES;
        cashinInfos.minimumScaleFactor = 12. / cashinInfos.font.pointSize;
        
        CGRectSetWidth(cashinInfos.frame, PPScreenWidth() - 80);
        CGRectSetXY(cashinInfos.frame, 40, 20);
        
        [cashinInfos setHeightToFit];
        
        CGRectSetHeight(headerView.frame, CGRectGetMaxY(cashinInfos.frame) + 20);
        
        [headerView addSubview:cashinInfos];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self createHeader];
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return methods.count;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
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
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 5, PPScreenWidth() - 20, 60)];
    
    [cell.contentView addSubview:view];
    
    [self fillCell:view data:methods[indexPath.row]];
    
    return cell;
}

- (void)fillCell:(UIView *)contentView data:(FLHomeButton *)buttonData {
    contentView.backgroundColor = [UIColor customBackground];
    contentView.layer.cornerRadius = 5;
    
    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(contentView.frame) / 2 - 15, 30, 30)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tintColor = [UIColor customBlue];
    
    if (buttonData.imgUrl && ![buttonData.imgUrl isBlank]) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:buttonData.imgUrl] placeholderImage:[[UIImage imageNamed:buttonData.defaultImg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] options:SDWebImageRefreshCached|SDWebImageContinueInBackground completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (imageView && !error) {
                imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        }];
    } else {
        imageView.image = [[UIImage imageNamed:buttonData.defaultImg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 15, 8, PPScreenWidth() - CGRectGetMaxX(imageView.frame) - 45, 15)];
    titleLabel.font = [UIFont customContentRegular:15];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = buttonData.title;
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 10. / titleLabel.font.pointSize;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 15, CGRectGetMaxY(titleLabel.frame), PPScreenWidth() - CGRectGetMaxX(imageView.frame) - 55, 30)];
    subtitleLabel.font = [UIFont customContentRegular:12];
    subtitleLabel.textColor = [UIColor customPlaceholder];
    subtitleLabel.text = buttonData.subtitle;
    subtitleLabel.numberOfLines = 2;
    subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    subtitleLabel.adjustsFontSizeToFitWidth = YES;
    subtitleLabel.minimumScaleFactor = 10. / titleLabel.font.pointSize;
    subtitleLabel.textAlignment = NSTextAlignmentLeft;
    
    UIImageView *nextIcon = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(contentView.frame) - 25, CGRectGetHeight(contentView.frame) / 2 - 10, 20, 20)];
    nextIcon.contentMode = UIViewContentModeScaleAspectFit;
    nextIcon.tintColor = [UIColor customBlue];
    nextIcon.image = [[UIImage imageNamed:@"arrow-right-accessory"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [contentView addSubview:imageView];
    [contentView addSubview:titleLabel];
    [contentView addSubview:subtitleLabel];
    [contentView addSubview:nextIcon];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLHomeButton *currentButton = methods[indexPath.row];
    
    [[FLTriggerManager sharedInstance] executeTriggerList:currentButton.triggers];
}

@end
