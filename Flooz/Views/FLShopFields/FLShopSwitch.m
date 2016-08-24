//
//  FLShopSwitch.m
//  Flooz
//
//  Created by Olive on 18/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLShopSwitch.h"
#import "FLSwitch.h"

@interface FLShopSwitch ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) FLSwitch *switchView;

@end

@implementation FLShopSwitch

- (id)initWithOptions:(NSDictionary *)options dic:(NSMutableDictionary *)dic {
    self = [super initWithOptions:options dic:dic];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, (CGRectGetWidth(self.frame) - 20) / 2, SHOP_FIELD_HEIGHT)];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.font = [UIFont customContentRegular:16];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.titleLabel.text = self.options[@"title"];
    
    self.switchView = [FLSwitch new];
    [self.switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];

    CGRectSetXY(self.switchView.frame, CGRectGetWidth(self.frame) - CGRectGetWidth(self.switchView.frame) - 10, SHOP_FIELD_HEIGHT / 2 - CGRectGetHeight(self.switchView.frame) / 2);
    
    if (self.options[@"default"]) {
        [self.dictionary setObject:self.options[@"default"] forKey:self.options[@"name"]];
        self.switchView.on = [self.options[@"default"] boolValue];
    } else {
        [self.dictionary setObject:@NO forKey:self.options[@"name"]];
        self.switchView.on = NO;
    }
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.switchView];
}

- (void)switchValueChanged {
    [self.switchView refreshColors];
    [self.dictionary setObject:@(self.switchView.on) forKey:self.options[@"name"]];
}

@end
