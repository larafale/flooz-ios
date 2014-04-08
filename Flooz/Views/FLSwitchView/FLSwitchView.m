//
//  FLSwitchView.m
//  Flooz
//
//  Created by jonathan on 2014-04-02.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLSwitchView.h"

@implementation FLSwitchView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:CGRectMake(0, frame.origin.y, frame.size.width, 50)];
    if (self) {
        [self createTitle:title];
        [self createSwitchView];
    }
    return self;
}

- (void)createTitle:(NSString *)title
{
    _title = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 0, CGRectGetHeight(self.frame))];
    
    _title.textColor = [UIColor whiteColor];
    _title.text = NSLocalizedString(title, nil);
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
    
    view.on = NO;
    [self didSwitchChange:view];
}

- (void)didSwitchChange:(UISwitch *)switchView
{
    if(switchView.on){
        [_delegate didSwitchViewSelected];
    }
    else{
        [_delegate didSwitchViewUnselected];
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
        [switchView setThumbTintColor:[UIColor customBackground]]; // Curseur
        [switchView setTintColor:[UIColor customBackground]]; // Bordure
        [switchView setOnTintColor:[UIColor customBackgroundHeader]]; // Couleur de fond
    }
}

@end
