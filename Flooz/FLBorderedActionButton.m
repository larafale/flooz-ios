//
//  FLBorderedActionButton.m
//  Flooz
//
//  Created by Epitech on 9/17/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "FLBorderedActionButton.h"

@interface FLBorderedActionButton ()

- (void)checkStateChangedAndSendActions;

@end

@implementation FLBorderedActionButton {
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
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 1;
    
    [self setTitle:title forState:UIControlStateNormal];
    
    [self setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];
    
    [self.titleLabel setFont:[UIFont customContentRegular:20]];
    self.tintColor = [self titleColorForState:self.state];
    self.layer.borderColor = self.tintColor.CGColor;
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
    self.layer.borderColor = self.tintColor.CGColor;
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
    self.layer.borderColor = self.tintColor.CGColor;
}

- (void)centerImage {
    [self centerImage:5];
}

- (void)centerImage:(CGFloat)margin {
    if ([self.titleLabel.text isBlank] || self.titleLabel.text == nil || self.titleLabel.text.length == 0) {
        CGRectSetY(self.imageView.frame, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.imageView.frame)) / 2.0f);
        CGRectSetX(self.imageView.frame, (CGRectGetWidth(self.frame) - CGRectGetWidth(self.imageView.frame)) / 2.0f);
    } else {
        [self.titleLabel setWidthToFit];
        
        //make the buttons content appear in the top-left
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        CGFloat totalWidth = CGRectGetWidth(self.imageView.frame) + CGRectGetWidth(self.titleLabel.frame) + margin;
        
        CGFloat imgX = (CGRectGetWidth(self.frame) - totalWidth) / 2.0f;
        CGFloat textX = imgX + CGRectGetWidth(self.imageView.frame) + margin;

        [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, textX, 0.0f, 0.0f)];

        CGRectSetY(self.imageView.frame, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.imageView.frame)) / 2.0f);
        CGRectSetX(self.imageView.frame, imgX);
    }
}

- (void) setCustomBadgeValue:(NSString *) value withFont:(UIFont *) font andFontColor:(UIColor *) color andBackgroundColor:(UIColor *) backColor {
    
}

- (void)setEnabled:(BOOL)enabled
{
    _priorState = self.state;
    [super setEnabled:enabled];
    [self checkStateChangedAndSendActions];
    
    if ([NSNumber numberWithInt:self.state])
        self.backgroundColor = backgroundColorDictionary[[NSNumber numberWithInt:self.state]];
    self.tintColor = [self titleColorForState:self.state];
    self.layer.borderColor = self.tintColor.CGColor;
}

- (void)setSelected:(BOOL)selected
{
    _priorState = self.state;
    [super setSelected:selected];
    [self checkStateChangedAndSendActions];
    
    if ([NSNumber numberWithInt:self.state])
        self.backgroundColor = backgroundColorDictionary[[NSNumber numberWithInt:self.state]];
    self.tintColor = [self titleColorForState:self.state];
    self.layer.borderColor = self.tintColor.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted
{
    _priorState = self.state;
    [super setHighlighted:highlighted];
    [self checkStateChangedAndSendActions];
    
    if ([NSNumber numberWithInt:self.state])
        self.backgroundColor = backgroundColorDictionary[[NSNumber numberWithInt:self.state]];
    self.tintColor = [self titleColorForState:self.state];
    self.layer.borderColor = self.tintColor.CGColor;
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
