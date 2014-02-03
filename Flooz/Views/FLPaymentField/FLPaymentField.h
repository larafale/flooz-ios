//
//  FLPaymentField.h
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPaymentField : UIView{
    __weak NSMutableDictionary *_dictionary;
    NSString *_dictionaryKey;
}

- (id)initWithFrame:(CGRect)frame for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey;
- (void)setStyleLight;

@end
