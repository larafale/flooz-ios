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

+ (dispatch_queue_t)animationQueue
{
    static dispatch_queue_t queue;
    if(!queue){
        queue = dispatch_queue_create("me.flooz.avatar", DISPATCH_QUEUE_SERIAL);
    }
    
    return queue;
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

- (void)setImageFromURLAnimate:(NSString *)url
{
    if(!url || [url isBlank] || [url isEqualToString:@"/img/nopic.png"]){
        [self showPlaceholder];
    }
    else{
        [self hidePlaceholder];
        //        [avatar sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder];
        
        avatar.layer.opacity = 0;
        
        dispatch_queue_t queue = [[self  class] animationQueue];
        
        dispatch_async(queue, ^{
            dispatch_suspend(queue);
            
            [avatar sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if(error){
                    dispatch_resume(queue);
                    return;
                }
                
                [UIView animateWithDuration:.3 animations:^{
                    avatar.layer.opacity = 1;
                    
                } completion:^(BOOL finished) {
                    dispatch_resume(queue);
                }];
            }];
        });
    }
}

- (void)setImageFromUser:(FLUser *)user
{
    if([user avatarURL:avatar.frame.size]){
        [self setImageFromURL:[user avatarURL:avatar.frame.size]];
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
