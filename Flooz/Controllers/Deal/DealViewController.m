//
//  DealViewController.m
//  Flooz
//
//  Created by Olive on 1/6/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "DealCell.h"
#import "DealCell2.h"
#import "DealViewController.h"
#import "FLPopupInformation.h"

@interface DealViewController () {
    NSInteger currentSelectedRow;
}

@property (nonatomic, strong) NSMutableArray *deals;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DealViewController

- (id)init {
    self = [super init];
    if (self) {
        currentSelectedRow = -1;
        self.title = NSLocalizedString(@"NAV_DEALS", @"");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *infosItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"popup-info"] style:UIBarButtonItemStylePlain target:self action:@selector(showPopupInfo)];
    
    self.navigationItem.rightBarButtonItem = infosItem;
    
    self.deals = [NSMutableArray new];
    
    FLDeal *deal = [[FLDeal alloc] initWithJSON:nil];
    deal.amount = @88;
    deal.amountType = FLDealAmountTypeVariable;
    deal.desc = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    deal.pic = @"https://res.cloudinary.com/dc1emihjc/image/upload/5_wwfk2a.png";
    deal.title = @"Offre de Bienvenue";
    
    [self.deals addObject:deal];
    
//    FLDeal *deal2 = [[FLDeal alloc] initWithJSON:nil];
//    deal2.amount = @100000;
//    deal2.amountType = FLDealAmountTypeFixed;
//    deal2.desc = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//    deal2.title = @"Offre de Bienvenue";
//    
//    [self.deals addObject:deal2];
//
//    FLDeal *deal3 = [[FLDeal alloc] initWithJSON:nil];
//    deal3.amount = @5;
//    deal3.amountType = FLDealAmountTypeVariable;
//    deal3.desc = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit.";
//    deal3.title = @"Offre de Bienvenue";
//    
//    [self.deals addObject:deal3];

    FLDeal *deal4 = [[FLDeal alloc] initWithJSON:nil];
    deal4.amount = @100;
    deal4.amountType = FLDealAmountTypeVariable;
    deal4.desc = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    deal4.pic = @"https://res.cloudinary.com/dc1emihjc/image/upload/5_wwfk2a.png";
    deal4.title = @"Offre de Bienvenue";
    
    [self.deals addObject:deal4];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor customBackgroundHeader]];
    [self.tableView setSeparatorColor:[UIColor customBackground]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setAllowsSelection:NO];
    [self.tableView setAllowsMultipleSelection:NO];
    
    [_mainBody addSubview:self.tableView];
}

#pragma mark - UITableView Delegate & Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLDeal *deal = [self.deals objectAtIndex:indexPath.row];
    return [DealCell2 getHeight:deal];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DealCell";
    DealCell2 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[DealCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    
    FLDeal *deal = [self.deals objectAtIndex:indexPath.row];
    [cell setDeal:deal];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentSelectedRow >= 0 && currentSelectedRow == indexPath.row) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        currentSelectedRow = -1;
    } else {
        currentSelectedRow = indexPath.row;
    }
}

#pragma mark - MGSwipeTableCellDelegate Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction {
    return (direction == MGSwipeDirectionRightToLeft);
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    if (fromExpansion) {
        [cell hideSwipeAnimated:YES];
    }
    
    return NO;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    
    MGSwipeButton *button = [MGSwipeButton buttonWithTitle:@"Partager" icon:[FLHelper colorImage:[FLHelper imageWithImage:[UIImage imageNamed:@"share"] scaledToSize:CGSizeMake(30, 30)] color:[UIColor whiteColor]] backgroundColor:[UIColor customPink]];
    [button centerIconOverText];
    
    return @[button];
}


- (void)showPopupInfo {
    UIImage *cbImage = [UIImage imageNamed:@"picto-cb"];
    CGSize newImgSize = CGSizeMake(20, 14);
    
    UIGraphicsBeginImageContextWithOptions(newImgSize, NO, 0.0);
    [cbImage drawInRect:CGRectMake(0, 0, newImgSize.width, newImgSize.height)];
    cbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = cbImage;
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_1", nil)];
    [string appendAttributedString:attachmentString];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_2", nil)]];
    
    [[[FLPopupInformation alloc] initWithTitle:NSLocalizedString(@"WALLET_INFOS_TITLE", nil) andMessage:string ok:nil] show];
}

@end
