//
//  FLMultiLineSegmentedControl.m
//  Flooz
//
//  Created by Epitech on 9/25/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "FLMultiLineSegmentedControl.h"
#import "UIView+LayerShot.h"

@interface FLMultiLineSegmentedControl ()

@property (nonatomic, retain) NSMutableArray *indexLabel;
@property (nonatomic, retain) NSMutableArray *indexSelectedLabel;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UILabel *labelSelected;

@end

@implementation FLMultiLineSegmentedControl
@synthesize label;
@synthesize labelSelected;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.indexLabel = [NSMutableArray new];
        self.indexSelectedLabel = [NSMutableArray new];
        
        [self addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)dealloc
{
    self.label = nil;
}

- (UILabel *)label
{
    if (!self->label) {
        self->label = [[UILabel alloc] initWithFrame:CGRectZero];
        self->label.textColor = [UIColor customBlue];
        self->label.backgroundColor = [UIColor clearColor];
        self->label.textAlignment = NSTextAlignmentCenter;
        self->label.numberOfLines = 2;
    }
    
    return self->label;
}

- (UILabel *)labelSelected
{
    if (!self->labelSelected) {
        self->labelSelected = [[UILabel alloc] initWithFrame:CGRectZero];
        self->labelSelected.textColor = [UIColor whiteColor];
        self->labelSelected.backgroundColor = [UIColor clearColor];
        self->labelSelected.textAlignment = NSTextAlignmentCenter;
        self->labelSelected.numberOfLines = 2;
    }
    
    return self->labelSelected;
}


- (void)setMultilineTitle:(NSAttributedString *)title forSegmentAtIndex:(NSUInteger)segment
{
    self.labelSelected.attributedText = title;
    self.label.attributedText = title;
    
    [self.label sizeToFit];
    [self.labelSelected sizeToFit];
    
    CGRectSetWidth(self.label.frame, CGRectGetWidth(self.frame) / 3);
    CGRectSetWidth(self.labelSelected.frame, CGRectGetWidth(self.frame) / 3);
   
    [self insertSegmentWithImage:[self.label.imageFromLayer imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:segment animated:YES];
    [self.indexLabel insertObject:[self.label.imageFromLayer imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:segment];
    [self.indexSelectedLabel insertObject:[self.labelSelected.imageFromLayer imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:segment];
}

- (void)updateMultilineTitle:(NSAttributedString *)title forSegmentAtIndex:(NSUInteger)segment {
    self.labelSelected.attributedText = title;
    self.label.attributedText = title;
    
    [self.label sizeToFit];
    [self.labelSelected sizeToFit];
    
    CGRectSetWidth(self.label.frame, CGRectGetWidth(self.frame) / 3);
    CGRectSetWidth(self.labelSelected.frame, CGRectGetWidth(self.frame) / 3);
    
    [self.indexLabel insertObject:[self.label.imageFromLayer imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:segment];
    [self.indexSelectedLabel insertObject:[self.labelSelected.imageFromLayer imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] atIndex:segment];

    for (int i = 0; i < self.numberOfSegments; i++) {
        if (i == self.selectedSegmentIndex) {
            [self setImage:[self.indexSelectedLabel objectAtIndex:i] forSegmentAtIndex:i];
        } else
            [self setImage:[self.indexLabel objectAtIndex:i] forSegmentAtIndex:i];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    [super setSelectedSegmentIndex:selectedSegmentIndex];
    
    for (int i = 0; i < self.numberOfSegments; i++) {
        if (i == self.selectedSegmentIndex) {
            [self setImage:[self.indexSelectedLabel objectAtIndex:i] forSegmentAtIndex:i];
        } else
            [self setImage:[self.indexLabel objectAtIndex:i] forSegmentAtIndex:i];
    }
}

-(void)segmentAction:(UISegmentedControl*)sender {
    for (int i = 0; i < self.numberOfSegments; i++) {
        if (i == self.selectedSegmentIndex) {
            [self setImage:[self.indexSelectedLabel objectAtIndex:i] forSegmentAtIndex:i];
        } else
            [self setImage:[self.indexLabel objectAtIndex:i] forSegmentAtIndex:i];
    }
}

+ (NSAttributedString *)itemTitleWithText:(NSString*)text andStat:(NSUInteger)data {
    NSMutableAttributedString *final = [[NSMutableAttributedString alloc] initWithString:@""];

    NSMutableAttributedString *statString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu\n", data]];
    [statString addAttribute:NSFontAttributeName value:[UIFont customContentBold:14] range:NSMakeRange(0, statString.length)];
    
    NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:text];
    [textString addAttribute:NSFontAttributeName value:[UIFont customContentRegular:13] range:NSMakeRange(0, text.length)];

    [final appendAttributedString:statString];
    [final appendAttributedString:textString];
    
    return final;
}

@end
