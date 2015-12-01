//
//  FLContryPicker.h
//  Flooz
//
//  Created by Epitech on 9/8/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLCountryPicker;

@protocol FLCountryPickerDelegate <UIPickerViewDelegate>

- (void)countryPicker:(FLCountryPicker *)picker didSelectCountry:(FLCountry *)country;

@end

@interface FLCountryPicker : UIPickerView

@property (nonatomic) id<FLCountryPickerDelegate> delegate;

@property (nonatomic, retain) NSArray *countries;
@property (nonatomic, retain) FLCountry *selectedCountry;

- (void)setSelectedCountryCode:(NSString *)countryCode animated:(BOOL)animated;
- (void)setSelectedCountryCode:(NSString *)countryCode;

- (FLCountry *)getSelectedCountry;

@end
