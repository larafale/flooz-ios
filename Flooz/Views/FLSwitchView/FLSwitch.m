//
//  FLSwitch.m
//  Flooz
//
//  Created by Arnaud on 2014-10-03.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLSwitch.h"

@implementation FLSwitch

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    [super setOn:on animated:animated];
    [self refreshColors:on];
}

- (void)setOn:(BOOL)on {
    [super setOn:on];
    [self refreshColors:on];
}

- (void)setAlternativeStyle {
    alternativeStyle = YES;
    [self refreshColors:self.on];
}

- (void)refreshColors {
    [self refreshColors:self.on];
}

- (void)refreshColors:(BOOL)on {
    if (on) {
        [self setThumbTintColor:[UIColor customBackgroundHeader]]; // Curseur
        [self setTintColor:[UIColor customBlue]]; // Bordure
        [self setOnTintColor:[UIColor customBlue]]; // Couleur de fond
    }
    else {
        [self setThumbTintColor:[UIColor customBackground]]; // Curseur
        
        if (!alternativeStyle) {
            [self setThumbTintColor:[UIColor customBackground]]; // Curseur
            [self setTintColor:[UIColor customBackground]]; // Bordure
        }
        else {
            [self setThumbTintColor:[UIColor customBackgroundHeader]]; // Curseur
            [self setTintColor:[UIColor customBackgroundHeader]]; // Bordure
        }
    }
}

@end
