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
//    self = [super initWithFrame:CGRectMake(0, frame.origin.y, frame.size.width, MAX(frame.size.height, 50))];
        self = [super initWithFrame:CGRectMake(0, frame.origin.y, frame.size.width, MAX(frame.size.height, 45))];
    if (self) {
        self.clipsToBounds = YES;
        alternativeStyle = NO;
        [self createTitle:title];
        [self createSwitchView];
    }
    return self;
}

+ (CGFloat)height
{
    return 50;
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
    switchView = [UISwitch new];
    
    CGRectSetXY(switchView.frame, CGRectGetWidth(self.frame) - 65, (CGRectGetHeight(self.frame) - CGRectGetHeight(switchView.frame)) / 2.);
    
    [switchView addTarget:self action:@selector(didSwitchChange) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:switchView];
    
    switchView.on = NO;
    [self didSwitchChange];
}

- (void)didSwitchChange
{
    if(switchView.on){
        [_delegate didSwitchViewSelected];
    }
    else{
        [_delegate didSwitchViewUnselected];
    }
    
    [self refreshSwitchViewColors];
}

- (void)refreshSwitchViewColors
{
    if(switchView.on){
        [switchView setThumbTintColor:[UIColor customBackground]]; // Curseur
        [switchView setTintColor:[UIColor customBlue]]; // Bordure
        [switchView setOnTintColor:[UIColor customBlue]]; // Couleur de fond
    }
    else{

        [switchView setOnTintColor:[UIColor customBackgroundHeader]]; // Couleur de fond
        
        if(alternativeStyle){
            [switchView setThumbTintColor:[UIColor customBackgroundHeader]]; // Curseur
            [switchView setTintColor:[UIColor customBackgroundHeader]]; // Bordure
        }
        else{
            [switchView setThumbTintColor:[UIColor customBackground]]; // Curseur
            [switchView setTintColor:[UIColor customBackground]]; // Bordure
        }
    }
}

- (void)setAlternativeStyle
{
    alternativeStyle = YES;
    [self refreshSwitchViewColors];
    
    _title.font = [UIFont customContentLight:14];
    [_title setWidthToFit];
}

- (void)setOn:(BOOL)on
{
    switchView.on = on;
    [self refreshSwitchViewColors];
}

@end
