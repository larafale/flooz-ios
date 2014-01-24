//
//  FLAccountButton.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLAccountButton.h"

@implementation FLAccountButton

- (id)initWithFrame:(CGRect)frame title:(NSString *)title imageNamed:(NSString *)imageNamed
{
    frame = CGRectSetWidthHeight(frame, SCREEN_WIDTH / 2., 130);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViewWithTitle:title imageNamed:imageNamed];
    }
    return self;
}

- (void)createViewWithTitle:(NSString *)title imageNamed:(NSString *)imageNamed
{
    self.backgroundColor = [UIColor customBackground];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor customSeparator].CGColor;
    
    [self setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateHighlighted];
    
    {
        UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        
        textView.textColor = [UIColor whiteColor];
        textView.textAlignment = NSTextAlignmentCenter;
        textView.font = [UIFont customContentLight:13];
        
        textView.text = title;
        
        [self addSubview:textView];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if(highlighted){
        self.backgroundColor = [UIColor customBlueHover];
    }
    else{
        self.backgroundColor = [UIColor customBackground];
    }
}

@end
