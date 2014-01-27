//
//  FLTextFieldIcon.h
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextFieldIcon : UIView<UITextFieldDelegate>{
    __weak NSMutableDictionary *_dictionnary;
    __weak NSString *_dictionnaryKey;
    
    UIImageView *icon;
    UITextField *_textfield;
}

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionnary key:(NSString *)dictionnaryKey position:(CGPoint)position;

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionnary key:(NSString *)dictionnaryKey position:(CGPoint)position placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionnaryKey2;


@end
