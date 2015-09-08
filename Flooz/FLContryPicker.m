//
//  FLContryPicker.m
//  Flooz
//
//  Created by Epitech on 9/8/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FLContryPicker.h"

@interface FLContryPicker () <UIPickerViewDelegate, UIPickerViewDataSource>

@end

@implementation FLContryPicker

@synthesize delegate;

- (void)setUp
{
    if ([Flooz sharedInstance].currentTexts)
        self.countries = [Flooz sharedInstance].currentTexts.avalaibleCountries;
    else {
        [[Flooz sharedInstance] textObjectFromApi:^(id result) {
            self.countries = [Flooz sharedInstance].currentTexts.avalaibleCountries;
        } failure:^(NSError *error) {
            if (!self.countries.count) {
                NSMutableArray *tmp = [NSMutableArray new];
                [tmp addObject:[[FLCountry alloc] initWithJSON:@{@"name":@"France", @"code":@"FR", @"phoneCode":@"+33"}]];
                self.countries = tmp;
            }
        }];
    }
    
    super.dataSource = self;
    super.delegate = self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
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
    for (long i = 0; i < self.countries.count; i++) {
        if ([[((FLCountry *)[self.countries objectAtIndex:i]) code] isEqualToString:countryCode]) {
            [self selectRow:i inComponent:0 animated:animated];
            self.selectedCountry = [self.countries objectAtIndex:i];
            break;
        }
    }
}

- (void)setSelectedCountryCode:(NSString *)countryCode
{
    [self setSelectedCountryCode:countryCode animated:NO];
}

- (FLCountry *)selectedCountry
{
    NSUInteger index = (NSUInteger)[self selectedRowInComponent:0];
    self.selectedCountry = [self.countries objectAtIndex:index];
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
        label.tag = 1;
        [view addSubview:label];
        
        UIImageView *flagView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 24, 24)];
        flagView.contentMode = UIViewContentModeScaleAspectFit;
        flagView.tag = 2;
        [view addSubview:flagView];
    }
    
    FLCountry *currentCountry = ((FLCountry *)[self.countries objectAtIndex:row]);
    
    ((UILabel *)[view viewWithTag:1]).text = [NSString stringWithFormat:@"%@ (%@)", currentCountry.name, currentCountry.phoneCode];
    ((UIImageView *)[view viewWithTag:2]).image = [UIImage imageNamed:currentCountry.imageName];
    
    return view;
}

- (void)pickerView:(__unused UIPickerView *)pickerView
      didSelectRow:(__unused NSInteger)row
       inComponent:(__unused NSInteger)component
{
    __strong id<FLCountryPickerDelegate> strongDelegate = delegate;
    [strongDelegate countryPicker:self didSelectCountry:[self selectedCountry]];
}

@end
