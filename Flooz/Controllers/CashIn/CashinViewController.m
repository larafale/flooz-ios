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
    NSMutableArray *methods;
    UIView *headerView;
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
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_CASHIN", nil);
    
    methods = [@[@{
                    @"title":NSLocalizedString(@"CASHIN_CARD_TITLE", nil),
                    @"subtitle":NSLocalizedString(@"CASHIN_CARD_SUBTITLE", nil),
                    @"img":@"cashin_cb",
                    @"controller": [CashinCreditCardViewController class]
                    }] mutableCopy];
    
    if ([[[Flooz sharedInstance] currentTexts] audiotelNumber])
        [methods addObject:@{
          @"title":NSLocalizedString(@"CASHIN_AUDIOTEL_TITLE", nil),
          @"subtitle":NSLocalizedString(@"CASHIN_AUDIOTEL_SUBTITLE", nil),
          @"img":@"cashin_phone",
          @"controller": [CashinAudiotelViewController class]
          }];
    
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
    
    [self registerNotification:@selector(createHeader) name:kNotificationReloadCurrentUser object:nil];
}

- (void)createHeader {
    if (!headerView) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
        
        UILabel *balanceHint = [[UILabel alloc] initWithText:@"Votre solde :" textColor:[UIColor customWhite] font:[UIFont customContentRegular:17] textAlignment:NSTextAlignmentLeft numberOfLines:1];
        balanceHint.tag = 42;
        
        UILabel *balanceLabel = [[UILabel alloc] initWithText:[FLHelper formatedAmount:[Flooz sharedInstance].currentUser.amount withCurrency:NO withSymbol:NO] textColor:[UIColor customBlue] font:[UIFont customContentBold:17]];
        balanceLabel.tag = 43;
        
        UILabel *currencySymbol = [[UILabel alloc] initWithText:NSLocalizedString(@"GLOBAL_EURO", nil) textColor:[UIColor customBlue] font:[UIFont customContentBold:14]];
        currencySymbol.tag = 44;
        
        CGFloat fullBalanceWidth = CGRectGetWidth(balanceHint.frame) + CGRectGetWidth(balanceLabel.frame) + CGRectGetWidth(currencySymbol.frame) + 7;
        
        CGRectSetXY(balanceHint.frame, PPScreenWidth() / 2 - fullBalanceWidth / 2, 30);
        CGRectSetXY(balanceLabel.frame, CGRectGetMaxX(balanceHint.frame) + 5, 30);
        CGRectSetXY(currencySymbol.frame, CGRectGetMaxX(balanceLabel.frame) + 2, 28);
        
        UILabel *cashinInfos = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_INFOS", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleLight:14] textAlignment:NSTextAlignmentCenter numberOfLines:3];
        cashinInfos.adjustsFontSizeToFitWidth = YES;
        cashinInfos.minimumScaleFactor = 12. / cashinInfos.font.pointSize;
        
        CGRectSetWidth(cashinInfos.frame, PPScreenWidth() - 80);
        CGRectSetXY(cashinInfos.frame, 40, CGRectGetMaxY(balanceLabel.frame) + 20);
        
        [cashinInfos setHeightToFit];
        
        CGRectSetHeight(headerView.frame, CGRectGetMaxY(cashinInfos.frame) + 20);
        
        [headerView addSubview:balanceHint];
        [headerView addSubview:balanceLabel];
        [headerView addSubview:currencySymbol];
        [headerView addSubview:cashinInfos];
    } else {
        UILabel *balanceHint = [headerView viewWithTag:42];
        UILabel *balanceLabel = [headerView viewWithTag:43];
        UILabel *currencySymbol = [headerView viewWithTag:44];
        
        [balanceLabel setText:[FLHelper formatedAmount:[Flooz sharedInstance].currentUser.amount withCurrency:NO withSymbol:NO]];
        [balanceLabel setWidthToFit];
        
        CGFloat fullBalanceWidth = CGRectGetWidth(balanceHint.frame) + CGRectGetWidth(balanceLabel.frame) + CGRectGetWidth(currencySymbol.frame) + 7;
        
        CGRectSetX(balanceHint.frame, PPScreenWidth() / 2 - fullBalanceWidth / 2);
        CGRectSetX(balanceLabel.frame, CGRectGetMaxX(balanceHint.frame) + 5);
        CGRectSetX(currencySymbol.frame, CGRectGetMaxX(balanceLabel.frame) + 2);
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

- (void)fillCell:(UIView *)contentView data:(NSDictionary *)buttonData {
    contentView.backgroundColor = [UIColor customBackground];
    contentView.layer.cornerRadius = 5;

    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(contentView.frame) / 2 - 15, 30, 30)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tintColor = [UIColor customBlue];
    
    imageView.image = [[UIImage imageNamed:buttonData[@"img"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 15, 8, PPScreenWidth() - CGRectGetMaxX(imageView.frame) - 45, 15)];
    titleLabel.font = [UIFont customContentRegular:15];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = buttonData[@"title"];
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 10. / titleLabel.font.pointSize;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 15, CGRectGetMaxY(titleLabel.frame), PPScreenWidth() - CGRectGetMaxX(imageView.frame) - 55, 30)];
    subtitleLabel.font = [UIFont customContentRegular:12];
    subtitleLabel.textColor = [UIColor customPlaceholder];
    subtitleLabel.text = buttonData[@"subtitle"];
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
    NSDictionary *rowData = methods[indexPath.row];
    
    if (rowData && rowData[@"controller"])
        [self.navigationController pushViewController:[rowData[@"controller"] new] animated:YES];
}

@end
