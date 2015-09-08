//
//  FLContryPicker.h
//  Flooz
//
//  Created by Epitech on 9/8/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLContryPicker;

@protocol FLCountryPickerDelegate <UIPickerViewDelegate>

- (void)countryPicker:(FLContryPicker *)picker didSelectCountry:(FLCountry *)country;

@end

@interface FLContryPicker : UIPickerView

@property (nonatomic, weak_delegate) id<FLCountryPickerDelegate> delegate;

@property (nonatomic, copy) NSArray *countries;
@property (nonatomic, copy) FLCountry *selectedCountry;

- (void)setSelectedCountryCode:(NSString *)countryCode animated:(BOOL)animated;

@end
