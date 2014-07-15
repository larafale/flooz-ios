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
    self.userInteractionEnabled = NO;
    
    avatar = [[UIImageView alloc] initWithFrame:CGRectMakeWithSize(self.frame.size)];
    placeholder = [UIImage imageNamed:@"default-avatar"];
    
    avatar.clipsToBounds = YES;
    avatar.layer.borderColor = [[UIColor customBackgroundHeader] CGColor];
    
    [self addSubview:avatar];
    
    [self showPlaceholder];
}

- (void)setImageFromURL:(NSString *)url
{
    if(!url || [url isBlank] || [url isEqualToString:@"/img/nopic.png"]){
        [self showPlaceholder];
    }
    else{
        [self hidePlaceholder];
        [avatar sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder];
    }
}

- (void)setImageFromUser:(FLUser *)user
{
    if([user avatarURL:avatar.frame.size]){
        [self hidePlaceholder];
        [avatar sd_setImageWithURL:[NSURL URLWithString:[user avatarURL:avatar.frame.size]] placeholderImage:placeholder];
    }
    else{
        [self showPlaceholder];
    }
}

- (void)setImageFromData:(NSData *)data
{
    if(data){
        [self hidePlaceholder];
        avatar.image = [UIImage imageWithData:data];
    }
    else{
        [self showPlaceholder];
    }
}

- (void)showPlaceholder
{
    avatar.image = placeholder;
    
//    CGFloat RATIO = .9;
//    CGRectSetWidthHeight(avatar.frame, CGRectGetWidth(self.frame) * RATIO, CGRectGetHeight(self.frame) * RATIO);
//    avatar.center = CGRectGetFrameCenter(self.frame);
    
    avatar.layer.cornerRadius = 0;
//    avatar.layer.borderWidth = 0;
}

- (void)hidePlaceholder
{
//    avatar.frame = CGRectMakeWithSize(self.frame.size);
    
    avatar.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.;
//    avatar.layer.borderWidth = 2.;
}

@end
