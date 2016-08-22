//
//  FLShopStepper.m
//  Flooz
//
//  Created by Olive on 18/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLShopStepper.h"

@interface FLShopStepper ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *amountLabel;
@property (nonatomic, strong) UIStepper *stepper;

@end

@implementation FLShopStepper

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
    
    self.stepper = [UIStepper new];
    self.stepper.autorepeat = NO;
    self.stepper.continuous = YES;
    self.stepper.wraps = NO;
    self.stepper.tintColor = [UIColor customBlue];
    
    CGRectSetXY(self.stepper.frame, CGRectGetWidth(self.frame) - CGRectGetWidth(self.stepper.frame) - 10, SHOP_FIELD_HEIGHT / 2 - CGRectGetHeight(self.stepper.frame) / 2);
    
    [self.stepper addTarget:self action:@selector(stepperValueChanged) forControlEvents:UIControlEventValueChanged];
    
    if (self.options[@"min"])
        self.stepper.minimumValue = [self.options[@"min"] doubleValue];

    if (self.options[@"max"])
        self.stepper.maximumValue = [self.options[@"max"] doubleValue];

    if (self.options[@"default"]) {
        [self.dictionary setObject:self.options[@"default"] forKey:self.options[@"name"]];
        self.stepper.value = [self.options[@"default"] doubleValue];
    } else {
        [self.dictionary setObject:@0 forKey:self.options[@"name"]];
        self.stepper.value = 0;
    }

    self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2 + 10, 0, CGRectGetWidth(self.frame) / 2 - 30 - CGRectGetWidth(self.stepper.frame), SHOP_FIELD_HEIGHT)];
    self.amountLabel.numberOfLines = 1;
    self.amountLabel.font = [UIFont customContentBold:17];
    self.amountLabel.textColor = [UIColor whiteColor];
    self.amountLabel.textAlignment = NSTextAlignmentRight;
    self.amountLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.amountLabel];
    [self addSubview:self.stepper];
    
    [self updateAmountLabel];
}

- (void)stepperValueChanged {
    [self.dictionary setObject:@(self.stepper.value) forKey:self.options[@"name"]];

    [self updateAmountLabel];
}

- (void)updateAmountLabel {
    self.amountLabel.text = [self.dictionary[self.options[@"name"]] stringValue];
}

@end
