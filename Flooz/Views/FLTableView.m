//
//  FLTableView.m
//  Flooz
//
//  Created by jonathan on 12/30/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "FLTableView.h"

@implementation FLTableView

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
    // Evite creation de cellule vide
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
    self.backgroundColor = [UIColor customBackground];
    self.separatorColor = [UIColor customSeparator];
    self.showsVerticalScrollIndicator = NO;
}

@end
