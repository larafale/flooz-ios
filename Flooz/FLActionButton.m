//
//  FLActionButton.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLActionButton.h"

@interface FLActionButton ()

- (void)checkStateChangedAndSendActions;

@end

@implementation FLActionButton {
    UIControlState  _priorState;
    
    NSMutableDictionary *backgroundColorDictionary;
}

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        backgroundColorDictionary = [NSMutableDictionary new];
        [self initViewWithTitle:title];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        backgroundColorDictionary = [NSMutableDictionary new];
        [self initViewWithTitle:@""];
    }
    return self;
}

- (void)initViewWithTitle:(NSString *)title {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 2;
    
    [self setTitle:title forState:UIControlStateNormal];
    
    [self setTitleColor:[UIColor customWhite] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor customWhite:0.5] forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor customWhite:0.5] forState:UIControlStateHighlighted];
    
    [self setBackgroundColor:[UIColor customBlue] forState:UIControlStateNormal];
    [self setBackgroundColor:[UIColor customBackground] forState:UIControlStateDisabled];
    [self setBackgroundColor:[UIColor customBlue:0.5] forState:UIControlStateHighlighted];
    
    [self.titleLabel setFont:[UIFont customContentRegular:20]];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    
    [backgroundColorDictionary setObject:backgroundColor forKey:[NSNumber numberWithInt:state]];
    
    if (state == self.state)
        self.backgroundColor = backgroundColorDictionary[[NSNumber numberWithInt:state]];
}

- (void)setImage:(UIImage *)image size:(CGSize)size {
    if (imageView) {
        [self.imageView setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    } else {
        self.imageView = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [self addSubview:self.imageView];
    }
    
    CGRectSetWidth(self.imageView.frame, size.width);
    CGRectSetHeight(self.imageView.frame, size.height);
    CGRectSetY(self.imageView.frame, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.imageView.frame)) / 2.0f);
    CGRectSetX(self.imageView.frame, 12.0f);
    [self.imageView setContentScaleFactor:UIViewContentModeScaleAspectFit];
    
    self.tintColor = [self titleColorForState:self.state];
}

- (void)setImageWithURL:(NSString *)imageURL size:(CGSize)size {
    if (imageView) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.imageView setImage:image];
        }];
    } else {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.imageView setImage:image];
        }];
        [self addSubview:self.imageView];
    }
    
    CGRectSetWidth(self.imageView.frame, size.width);
    CGRectSetHeight(self.imageView.frame, size.height);
    CGRectSetY(self.imageView.frame, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.imageView.frame)) / 2.0f);
    CGRectSetX(self.imageView.frame, 12.0f);
    [self.imageView setContentScaleFactor:UIViewContentModeScaleAspectFit];
    
    self.tintColor = [self titleColorForState:self.state];
}

- (void)setEnabled:(BOOL)enabled
{
    _priorState = self.state;
    [super setEnabled:enabled];
    [self checkStateChangedAndSendActions];
    
    if ([NSNumber numberWithInt:self.state])
        self.backgroundColor = backgroundColorDictionary[[NSNumber numberWithInt:self.state]];
    self.tintColor = [self titleColorForState:self.state];
}

- (void)setSelected:(BOOL)selected
{
    _priorState = self.state;
    [super setSelected:selected];
    [self checkStateChangedAndSendActions];
    
    if ([NSNumber numberWithInt:self.state])
        self.backgroundColor = backgroundColorDictionary[[NSNumber numberWithInt:self.state]];
    self.tintColor = [self titleColorForState:self.state];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _priorState = self.state;
    [super setHighlighted:highlighted];
    [self checkStateChangedAndSendActions];
    
    if ([NSNumber numberWithInt:self.state])
        self.backgroundColor = backgroundColorDictionary[[NSNumber numberWithInt:self.state]];
    self.tintColor = [self titleColorForState:self.state];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    _priorState = self.state;
    [super touchesBegan:touches withEvent:event];
    [self checkStateChangedAndSendActions];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    _priorState = self.state;
    [super touchesMoved:touches withEvent:event];
    [self checkStateChangedAndSendActions];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    _priorState = self.state;
    [super touchesEnded:touches withEvent:event];
    [self checkStateChangedAndSendActions];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    _priorState = self.state;
    [super touchesCancelled:touches withEvent:event];
    [self checkStateChangedAndSendActions];
}

#pragma mark - Private interface implementation
- (void)checkStateChangedAndSendActions
{
    if(self.state != _priorState)
    {
        _priorState = self.state;
        [self sendActionsForControlEvents:UIControlEventStateChanged];
    }
}

@end
