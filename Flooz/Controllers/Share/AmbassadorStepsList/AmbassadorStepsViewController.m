//
//  AmbassadorStepsViewController.m
//  Flooz
//
//  Created by Olive on 4/4/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "AmbassadorStepsViewController.h"

#define PADDING_SIDE 0

@interface AmbassadorStepsViewController ()

@end

@implementation AmbassadorStepsViewController {
    CGFloat viewHeight;
    CGFloat viewWidth;
    
    UIView *contentView;
    UITableView *tableView;
    
    NSArray *steps;
    NSDictionary *currentStep;
}

- (id)init {
    self = [super init];
    if (self) {
        viewWidth = 220;
        
        currentStep = [Flooz sharedInstance].currentUser.currentAmbassadorStep;
        steps = [Flooz sharedInstance].invitationTexts.shareSteps;
        
        viewHeight = 25 * steps.count + 30 + 10;
        
        [self setPreferredContentSize:CGSizeMake(viewWidth + 20, viewHeight)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, viewWidth, viewHeight - 10)];
    
    [contentView.layer setMasksToBounds:YES];
    [contentView.layer setCornerRadius:5];
    contentView.backgroundColor = [UIColor customBackgroundHeader];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight - 10 + 1.5) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor customBackground];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.bounces = NO;
    tableView.scrollEnabled = NO;
    tableView.allowsSelection = NO;
    
    if ([tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 30)];
    headerView.backgroundColor = [UIColor customBackground];
    
    UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIDE, 5, viewWidth / 2 - PADDING_SIDE, 20)];
    goalLabel.numberOfLines = 1;
    goalLabel.font = [UIFont customContentBold:13];
    goalLabel.textAlignment = NSTextAlignmentCenter;
    goalLabel.textColor = [UIColor customPlaceholder];
    goalLabel.text = @"Inscriptions";
    
    [headerView addSubview:goalLabel];
    
    UILabel *rewardLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth / 2 + 10, 5, viewWidth / 2 - PADDING_SIDE, 20)];
    rewardLabel.numberOfLines = 1;
    rewardLabel.font = [UIFont customContentBold:13];
    rewardLabel.textAlignment = NSTextAlignmentCenter;
    rewardLabel.textColor = [UIColor customPlaceholder];
    rewardLabel.text = @"Rémunération";
    
    CGRectSetX(rewardLabel.frame, viewWidth - CGRectGetWidth(rewardLabel.frame) - PADDING_SIDE);
    
    [headerView addSubview:rewardLabel];

    tableView.tableHeaderView = headerView;
    
    [contentView addSubview:tableView];

    UIButton *closeButton = [UIButton newWithFrame:CGRectMake(viewWidth, 0, 20, 20)];
    [closeButton setImage:[UIImage imageNamed:@"image-close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:contentView];
    [self.view addSubview:closeButton];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return steps.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AmbassadorStepCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        // Remove seperator inset
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIDE, 5, viewWidth / 2 - PADDING_SIDE, 15)];
        goalLabel.numberOfLines = 1;
        goalLabel.font = [UIFont customContentRegular:13];
        goalLabel.textAlignment = NSTextAlignmentCenter;
        goalLabel.textColor = [UIColor whiteColor];
        goalLabel.tag = 60;
        
        [cell.contentView addSubview:goalLabel];
        
        UILabel *rewardLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth / 2, 5, viewWidth / 2 - PADDING_SIDE, 15)];
        rewardLabel.numberOfLines = 1;
        rewardLabel.font = [UIFont customContentBold:12];
        rewardLabel.textAlignment = NSTextAlignmentCenter;
        rewardLabel.textColor = [UIColor whiteColor];
        rewardLabel.tag = 61;
        
        [cell.contentView addSubview:rewardLabel];
    }
    
    UILabel *goalLabel = [cell viewWithTag:60];
    
    NSString *goalString = steps[indexPath.row][0];
    
    NSInteger goalInt = [goalString integerValue];
    
    if ([currentStep[@"count"] integerValue] == goalInt)
        cell.backgroundColor = [UIColor customBlue];
    else
        cell.backgroundColor = [UIColor clearColor];
    
    goalLabel.text = [NSString stringWithFormat:@"%@ filleuls", goalString];

    NSString *rewardString = [FLHelper formatedAmount:steps[indexPath.row][1] withCurrency:YES withSymbol:NO];

    UILabel *rewardLabel = [cell viewWithTag:61];
    rewardLabel.text = rewardString;

    return cell;
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        _formSheet = [[MZFormSheetController alloc] initWithViewController:self];
        _formSheet.presentedFormSheetSize = self.preferredContentSize;
        _formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
        _formSheet.shadowRadius = 2.0;
        _formSheet.shadowOpacity = 0.3;
        _formSheet.shouldDismissOnBackgroundViewTap = YES;
        _formSheet.shouldCenterVertically = YES;
        _formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsDoNothing;
        
        [[appDelegate myTopViewController] mz_presentFormSheetController:_formSheet animated:YES completionHandler:nil];
    });
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[appDelegate myTopViewController] mz_dismissFormSheetControllerAnimated:YES completionHandler: ^(MZFormSheetController *formSheetController) {
            _formSheet = nil;
        }];
    });
}

@end
