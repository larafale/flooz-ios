//
//  FLContryPicker.m
//  Flooz
//
//  Created by Epitech on 9/8/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FLCountryPicker.h"

@interface FLCountryPicker () <UIPickerViewDelegate, UIPickerViewDataSource>

@end

@implementation FLCountryPicker

@synthesize delegate;

- (void)setUp
{
    [[Flooz sharedInstance] textObjectFromApi:^(id result) {
        self.countries = [Flooz sharedInstance].currentTexts.avalaibleCountries;
    } failure:^(NSError *error) {
        if (!self.countries.count) {
            NSMutableArray *tmp = [NSMutableArray new];
            [tmp addObject:[FLCountry defaultCountry]];
            self.countries = tmp;
        }
    }];
    
    super.dataSource = self;
    super.delegate = self;
    
    self.hidePhoneHint = NO;
    self.backgroundColor = [UIColor customBackground];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)setDataSource:(__unused id<UIPickerViewDataSource>)dataSource
{
    //does nothing
}

- (void)setSelectedCountryCode:(NSString *)countryCode animated:(BOOL)animated
{
    if (!self.countries.count) {
        NSMutableArray *tmp = [NSMutableArray new];
        [tmp addObject:[FLCountry defaultCountry]];
        self.countries = tmp;
    } else {
        for (long i = 0; i < self.countries.count; i++) {
            if ([[((FLCountry *)[self.countries objectAtIndex:i]) code] isEqualToString:countryCode]) {
                [self selectRow:i inComponent:0 animated:animated];
                self.selectedCountry = [self.countries objectAtIndex:i];
                break;
            }
        }
    }
}

- (void)setSelectedCountryCode:(NSString *)countryCode
{
    [self setSelectedCountryCode:countryCode animated:NO];
}

- (void)setSelectedCountryName:(NSString *)country animated:(BOOL)animated
{
    if (!self.countries.count) {
        NSMutableArray *tmp = [NSMutableArray new];
        [tmp addObject:[FLCountry defaultCountry]];
        self.countries = tmp;
    } else {
        for (long i = 0; i < self.countries.count; i++) {
            if ([[((FLCountry *)[self.countries objectAtIndex:i]) name] isEqualToString:country]) {
                [self selectRow:i inComponent:0 animated:animated];
                self.selectedCountry = [self.countries objectAtIndex:i];
                break;
            }
        }
    }
}

- (void)setSelectedCountryName:(NSString *)country
{
    [self setSelectedCountryName:country animated:NO];
}

- (FLCountry *)getSelectedCountry {
    return self.selectedCountry;
}

#pragma mark -
#pragma mark UIPicker

- (NSInteger)numberOfComponentsInPickerView:(__unused UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(__unused UIPickerView *)pickerView numberOfRowsInComponent:(__unused NSInteger)component
{
    return (NSInteger)[self.countries count];
}

- (UIView *)pickerView:(__unused UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(__unused NSInteger)component reusingView:(UIView *)view
{
    if (!view)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35, 3, 245, 24)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.tag = 1;
        [view addSubview:label];
        
        UIImageView *flagView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 24, 24)];
        flagView.contentMode = UIViewContentModeScaleAspectFit;
        flagView.tag = 2;
        [view addSubview:flagView];
    }
    
    FLCountry *currentCountry = ((FLCountry *)[self.countries objectAtIndex:row]);
    
    if (self.hidePhoneHint)
        ((UILabel *)[view viewWithTag:1]).text = [NSString stringWithFormat:@"%@", currentCountry.name];
    else
        ((UILabel *)[view viewWithTag:1]).text = [NSString stringWithFormat:@"%@ (%@)", currentCountry.name, currentCountry.phoneCode];
    
    ((UIImageView *)[view viewWithTag:2]).image = [UIImage imageNamed:currentCountry.imageName];
    
    return view;
}

- (void)pickerView:(__unused UIPickerView *)pickerView
      didSelectRow:(__unused NSInteger)row
       inComponent:(__unused NSInteger)component
{
    self.selectedCountry = [self.countries objectAtIndex:row];
    
    __strong id<FLCountryPickerDelegate> strongDelegate = delegate;
    [strongDelegate countryPicker:self didSelectCountry:self.selectedCountry];
}

@end
