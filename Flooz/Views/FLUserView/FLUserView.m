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
    filter = [UIImageView imageNamed:@"avatar-filter"];
    avatar = [[UIImageView alloc] initWithFrame:CGRectMakeWithSize(self.frame.size)];

    filter.frame = CGRectMakeWithSize(self.frame.size);
    placeholder = [UIImage imageNamed:@"default-avatar"];
    avatar.image = placeholder;
        
    [self addSubview:avatar];
    [self addSubview:filter];
}

- (void)setAlternativeStyle
{
    [filter removeFromSuperview];
    filter = [UIImageView imageNamed:@"avatar-filter2"];
    filter.frame = CGRectMakeWithSize(self.frame.size);
    [self addSubview:filter];
}

- (void)setAlternativeStyle2
{
    [filter removeFromSuperview];
    filter = [UIImageView imageNamed:@"avatar-filter3"];
    filter.frame = CGRectMakeWithSize(self.frame.size);
    [self addSubview:filter];
}

- (void)setImageFromURL:(NSString *)url
{
    if(!url || [url isBlank] || [url isEqualToString:@"/img/nopic.png"]){
        avatar.image = placeholder;
        filter.hidden = YES;
    }
    else{
        [avatar setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder];
        filter.hidden = NO;
    }
}

- (void)setImageFromUser:(FLUser *)user
{
    if([user avatarURL:avatar.frame.size]){
        [avatar setImageWithURL:[NSURL URLWithString:[user avatarURL:avatar.frame.size]] placeholderImage:placeholder];
        filter.hidden = NO;
    }
    else{
        filter.hidden = YES;
    }
}

- (void)setImageFromData:(NSData *)data
{
    if(data){
        avatar.image = [UIImage imageWithData:data];
        filter.hidden = NO;
    }
    else{
        avatar.image = placeholder;
        filter.hidden = YES;
    }
}

@end
