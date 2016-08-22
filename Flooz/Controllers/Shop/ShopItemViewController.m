//
//  ShopItemViewController.m
//  Flooz
//
//  Created by Olive on 16/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ShopItemViewController.h"
#import "TUSafariActivity.h"
#import "ARChromeActivity.h"
#import "FLCopyLinkActivity.h"
#import "WebViewController.h"

@interface ShopItemViewController () {
    UIBarButtonItem *shareItem;
    
    UIScrollView *contentView;
    UIImageView *imageView;
    UILabel *valueLabel;
    UILabel *descriptionLabel;
    UILabel *tosLabel;
    
    FLActionButton *buyButton;
}

@property (nonatomic, strong) FLShopItem *currentItem;

@end

@implementation ShopItemViewController

- (id)initWithItem:(FLShopItem *)item {
    self = [super init];
    if (self) {
        self.currentItem = item;
    }
    return self;
}

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        self.currentItem = [[FLShopItem alloc] initWithJson:self.triggerData[@"item"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.currentItem.name;
    
    shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    [shareItem setTintColor:[UIColor customBlue]];
    
    if (self.currentItem.shareUrl)
        self.navigationItem.rightBarButtonItem = shareItem;

    CGFloat maxHeight = 0;
    
    buyButton = [[FLActionButton alloc] initWithFrame:CGRectMake(30, CGRectGetHeight(_mainBody.frame) - FLActionButtonDefaultHeight - 15, PPScreenWidth() - 60, FLActionButtonDefaultHeight) title:@"Acheter"];
    [buyButton addTarget:self action:@selector(buyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame) - (CGRectGetHeight(_mainBody.frame) - CGRectGetMinY(buyButton.frame)) - 10)];
    contentView.bounces = NO;
    contentView.showsVerticalScrollIndicator = NO;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, PPScreenWidth() - 40, [FLHelper cardScaleHeightFromWidth:PPScreenWidth() - 40])];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 5.0f;

    [imageView sd_setImageWithURL:[NSURL URLWithString:self.currentItem.pic]];
    
    maxHeight = CGRectGetMaxY(imageView.frame) + 10;
    
    [contentView addSubview:imageView];

    if (self.currentItem.value) {
        valueLabel = [[UILabel alloc] initWithText:self.currentItem.value textColor:[UIColor customBlue] font:[UIFont customContentBold:25] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        
        CGRectSetXY(valueLabel.frame, PPScreenWidth() / 2 - CGRectGetWidth(valueLabel.frame) / 2, maxHeight + 5);
        
        maxHeight = CGRectGetMaxY(valueLabel.frame) + 10;
        
        [contentView addSubview:valueLabel];
    }
    
    descriptionLabel = [[UILabel alloc] initWithText:self.currentItem.description textColor:[UIColor whiteColor] font:[UIFont customContentRegular:14] textAlignment:NSTextAlignmentJustified numberOfLines:0];
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGRectSetWidth(descriptionLabel.frame, PPScreenWidth() - 30);
    CGRectSetXY(descriptionLabel.frame, 15, maxHeight + 10);
    
    [descriptionLabel setHeightToFit];
    
    maxHeight = CGRectGetMaxY(descriptionLabel.frame) + 10;

    [contentView addSubview:descriptionLabel];
    
    if (self.currentItem.tosString) {
        tosLabel = [[UILabel alloc] initWithText:@"Conditions d'utilisation" textColor:[UIColor customPlaceholder] font:[UIFont customContentLight:13] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        [tosLabel addTapGestureWithTarget:self action:@selector(didToSButtonClick)];
        
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        tosLabel.attributedText = [[NSAttributedString alloc] initWithString:tosLabel.text attributes:underlineAttribute];
        
        CGRectSetXY(tosLabel.frame, PPScreenWidth() / 2 - CGRectGetWidth(tosLabel.frame) / 2, maxHeight + 5);

        maxHeight = CGRectGetMaxY(tosLabel.frame) + 10;
        
        [contentView addSubview:tosLabel];
    }
    
    [contentView setContentSize:CGSizeMake(PPScreenWidth(), maxHeight)];
    
    [_mainBody addSubview:buyButton];
    [_mainBody addSubview:contentView];
}

- (void)buyButtonClick {
    [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:self.currentItem.purchaseTriggers]];
}

- (void)didToSButtonClick {
    WebViewController *controller = [WebViewController new];
    [controller setUrl:self.currentItem.tosString];
    controller.title = self.title;
    
    [[self navigationController] pushViewController:controller animated:YES];

}

- (void)share {
    NSURL *url = [NSURL URLWithString:self.currentItem.shareUrl];
    
    ARChromeActivity *chromeActivity = [ARChromeActivity new];
    TUSafariActivity *safariActivity = [TUSafariActivity new];
    FLCopyLinkActivity *copyActivity = [FLCopyLinkActivity new];
    
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:@[chromeActivity, safariActivity, copyActivity]];
    
    [shareController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
    }];
    
    [shareController setExcludedActivityTypes:@[UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeAirDrop]];
    
    [self.navigationController presentViewController:shareController animated:YES completion:nil];

}

@end
