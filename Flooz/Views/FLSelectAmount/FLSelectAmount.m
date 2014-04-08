//
//  FLSelectAmount.m
//  Flooz
//
//  Created by jonathan on 2/5/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLSelectAmount.h"

@implementation FLSelectAmount

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, frame.origin.y, SCREEN_WIDTH, 50)];
    if (self) {        
        [self createTitle];
        [self createSwitchView];
    }
    return self;
}

- (void)createTitle
{
    _title = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 0, CGRectGetHeight(self.frame))];
    
    _title.textColor = [UIColor whiteColor];
    _title.text = NSLocalizedString(@"TRANSACTION_FIELD_GOAL", nil);
    _title.font = [UIFont customContentRegular:12];
    
    [_title setWidthToFit];
    
    [self addSubview:_title];
}

- (void)createSwitchView
{
    UISwitch *view = [UISwitch new];
    
    CGRectSetXY(view.frame, CGRectGetWidth(self.frame) - 65, (CGRectGetHeight(self.frame) - CGRectGetHeight(view.frame)) / 2.);
    
        [view addTarget:self action:@selector(didSwitchChange:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:view];
    
    view.on = YES;
    [self didSwitchChange:view];
}

- (void)didSwitchChange:(UISwitch *)switchView
{
    if(switchView.on){
         [_delegate didAmountFixSelected];
    }
    else{
        [_delegate didAmountFreeSelected];
    }
    
    [self refreshSwitchViewColors:switchView];
}

- (void)refreshSwitchViewColors:(UISwitch *)switchView{
    if(switchView.on){
        [switchView setThumbTintColor:[UIColor customBackground]]; // Curseur
        [switchView setTintColor:[UIColor customBlue]]; // Bordure
        [switchView setOnTintColor:[UIColor customBlue]]; // Couleur de fond
    }
    else{
        [switchView setThumbTintColor:[UIColor customBackgroundHeader]]; // Curseur
        [switchView setTintColor:[UIColor customBackgroundHeader]]; // Bordure
        [switchView setOnTintColor:[UIColor customBackgroundHeader]]; // Couleur de fond
    }
}

@end
