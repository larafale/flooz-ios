//
//  FLSlide.m
//  Flooz
//
//  Created by Epitech on 3/31/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FLSlide.h"
#import "UIImageView+AFNetworking.h"

@interface FLSlide () {
    EAIntroView* introView;
}

@end

@implementation FLSlide

- (id)initWithJson:(NSDictionary*)json {
    self = [super init];
    if (self) {
        [self setJson:json];
    }
    return self;
}

- (void)setJson:(NSDictionary*)json {
    self.text = json[@"text"];
    self.imgURL = json[@"image"];
    self.skipText = json[@"skip"];
    
    if (!self.skipText || [self.skipText isBlank])
        self.skipText = NSLocalizedString(@"SkipLast", nil);
    
    self.page = [EAIntroPage page];
    self.page.desc = self.text;
    self.page.descFont = [UIFont customContentRegular:18];
    self.page.descWidth = SCREEN_WIDTH - 75;
    self.page.descPositionY = 170;
    self.page.bgImage = [UIImage imageNamed:@"back-secure"];
    
    if (self.imgURL && ![self.imgURL isBlank]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imgURL]];
        
        self.page.titleIconView = imageView;
    }
}

- (void)finishSlider {
    [introView hideWithFadeOutDuration:0.3];
}

- (void)enableLastPageConfig:(EAIntroView*)intro {
    introView = intro;
    
    UIButton *lastButton = [[UIButton alloc] initWithFrame:CGRectMake(50, SCREEN_HEIGHT - 80, SCREEN_WIDTH - 100, 40)];
    [lastButton setTitle:self.skipText forState:UIControlStateNormal];
    lastButton.layer.masksToBounds = YES;
    lastButton.layer.cornerRadius = 20;
    lastButton.layer.borderColor = [UIColor whiteColor].CGColor;
    lastButton.layer.borderWidth = 1;
    lastButton.layer.backgroundColor = [UIColor customBlue].CGColor;
    [lastButton.titleLabel setFont:[UIFont customContentBold:18]];

    [lastButton addTarget:self action:@selector(finishSlider) forControlEvents:UIControlEventTouchUpInside];
    
    self.page.subviews = @[lastButton];
    
    self.page.onPageDidAppear = ^{
        intro.skipButton.hidden = YES;
        intro.pageControl.hidden = YES;
    };
    
    self.page.onPageDidDisappear = ^{
        intro.skipButton.hidden = NO;
        intro.pageControl.hidden = NO;
    };
}

@end
