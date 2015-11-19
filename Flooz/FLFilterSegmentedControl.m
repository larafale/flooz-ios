//
//  FLFilterSegmentedControl.m
//  Flooz
//
//  Created by Epitech on 9/30/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "FLFilterSegmentedControl.h"
#import "UIView+LayerShot.h"

@interface FLFilterSegmentedControl () {
    UIImage *selectedAllIcon;
    UIImage *selectedFriendIcon;
    UIImage *selectedPrivateIcon;
    
    UIImage *allIcon;
    UIImage *friendIcon;
    UIImage *privateIcon;
}

@end

@implementation FLFilterSegmentedControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTintColor:[UIColor customBlue]];
        [self addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        
        CGFloat filterItemImgSize = CGRectGetHeight(frame) - 8;
        
        allIcon = [FLHelper imageWithImage:[UIImage imageNamed:@"transaction-scope-public"] scaledToSize:CGSizeMake(filterItemImgSize, filterItemImgSize)];
        friendIcon = [FLHelper imageWithImage:[UIImage imageNamed:@"transaction-scope-friend"] scaledToSize:CGSizeMake(filterItemImgSize, filterItemImgSize)];
        privateIcon = [FLHelper imageWithImage:[UIImage imageNamed:@"transaction-scope-private"] scaledToSize:CGSizeMake(filterItemImgSize, filterItemImgSize)];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, filterItemImgSize, filterItemImgSize)];
        [imgView setContentMode:UIViewContentModeScaleAspectFill];
        [imgView setTintColor:[UIColor whiteColor]];
        
        [imgView setImage:[[UIImage imageNamed:@"transaction-scope-public"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        selectedAllIcon = [imgView.imageFromLayer imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        [imgView setImage:[[UIImage imageNamed:@"transaction-scope-friend"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        selectedFriendIcon = [imgView.imageFromLayer imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        [imgView setImage:[[UIImage imageNamed:@"transaction-scope-private"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        selectedPrivateIcon = [imgView.imageFromLayer imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        [self insertSegmentWithImage:allIcon atIndex:0 animated:NO];
        [self insertSegmentWithImage:friendIcon atIndex:1 animated:NO];
        [self insertSegmentWithImage:privateIcon atIndex:2 animated:NO];

    }
    return self;
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    [super setSelectedSegmentIndex:selectedSegmentIndex];
    
    [self valueChanged:self];
}

- (void)valueChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self setImage:selectedAllIcon forSegmentAtIndex:0];
        [self setImage:friendIcon forSegmentAtIndex:1];
        [self setImage:privateIcon forSegmentAtIndex:2];
    } else if (sender.selectedSegmentIndex == 1) {
        [self setImage:allIcon forSegmentAtIndex:0];
        [self setImage:selectedFriendIcon forSegmentAtIndex:1];
        [self setImage:privateIcon forSegmentAtIndex:2];
    } else if (sender.selectedSegmentIndex == 2) {
        [self setImage:allIcon forSegmentAtIndex:0];
        [self setImage:friendIcon forSegmentAtIndex:1];
        [self setImage:selectedPrivateIcon forSegmentAtIndex:2];
    }
}

@end
