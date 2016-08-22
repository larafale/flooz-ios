//
//  FLShopTextField.m
//  Flooz
//
//  Created by Olive on 18/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLShopTextField.h"

@interface FLShopField ()

@property (nonatomic, strong) FLTextField *textfield;

@end

@implementation FLShopTextField

@synthesize textfield;

- (id)initWithOptions:(NSDictionary *)options dic:(NSMutableDictionary *)dic {
    self = [super initWithOptions:options dic:dic];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    if (self.options[@"default"])
        [self.dictionary setObject:self.options[@"default"] forKey:self.options[@"name"]];
    
    self.textfield = [[FLTextField alloc] initWithPlaceholder:self.options[@"placeholder"] for:self.dictionary key:self.options[@"name"] frame:CGRectMake(10, 5, CGRectGetWidth(self.frame) - 20, SHOP_FIELD_HEIGHT - 10)];
    [self.textfield setType:FLTextFieldTypeText];
    
    NSString *type = [self.options[@"placeholder"] stringByReplacingOccurrencesOfString:@"textfield:" withString:@""];
    
    if ([type isEqualToString:@"date"]) {
        [self.textfield setType:FLTextFieldTypeDate];
    } else if ([type isEqualToString:@"integer"]) {
        [self.textfield setType:FLTextFieldTypeNumber];
    } else if ([type isEqualToString:@"float"]) {
        [self.textfield setType:FLTextFieldTypeFloatNumber];
    } else if ([type isEqualToString:@"text"]) {
        [self.textfield setType:FLTextFieldTypeText];
    } else if ([type isEqualToString:@"password"]) {
        [self.textfield setType:FLTextFieldTypePassword];
    } else if ([type isEqualToString:@"email"]) {
        [self.textfield setType:FLTextFieldTypeEmail];
    } else if ([type isEqualToString:@"url"]) {
        [self.textfield setType:FLTextFieldTypeURL];
    }
    
    if (self.options[@"maxLenght"])
        [self.textfield setMaxLenght:[self.options[@"maxLenght"] integerValue]];
    
    [self addSubview:self.textfield];
}

@end
