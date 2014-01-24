//
//  FLUserView.m
//  Flooz
//
//  Created by jonathan on 1/23/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLUserView.h"

@implementation FLUserView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{    
    UIImageView *filter = [UIImageView imageNamed:@"avatar-filter"];
    avatar = [[UIImageView alloc] initWithFrame:CGRectMakeWithSize(self.frame.size)];

    filter.frame = CGRectMakeWithSize(self.frame.size);
    placeholder = [UIImage imageNamed:@"default-avatar"];
    avatar.image = placeholder;
    
    [self addSubview:avatar];
    [self addSubview:filter];
}

- (void)setImageFromURL:(NSString *)url
{
    [avatar setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder];
}

@end
