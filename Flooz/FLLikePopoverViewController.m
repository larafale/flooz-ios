//
//  FLLikePopoverViewController.m
//  Flooz
//
//  Created by Epitech on 12/31/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLLikePopoverViewController.h"

@interface FLLikePopoverViewController () {
    FLTransaction *transaction;
    
    UITableView *_tableView;
    CGFloat viewHeight;
    CGFloat viewWidth;
}

@end

#define LIKE_CELL_HEIGHT 25.0f
#define LIKE_TEXT_HEIGHT 14.0f

@implementation FLLikePopoverViewController

- (id)initWithTransaction:(FLTransaction*)transac {
    self = [super init];
    if (self) {
        transaction = transac;
        
        CGFloat maxHeight = PPScreenHeight() / 3;
        CGFloat totalHeight = LIKE_CELL_HEIGHT * transaction.social.likesCount;
        
        if (totalHeight <= maxHeight)
            viewHeight = totalHeight;
        else {
            viewHeight = maxHeight;
        }
        
        viewWidth = 0;
        
        NSDictionary *labelAttributes = @{NSFontAttributeName: [UIFont customContentRegular:LIKE_TEXT_HEIGHT]};

        for (NSDictionary *like in transaction.social.likes) {
            CGSize labelSize = [[NSString stringWithFormat:@"@%@", like[@"nick"]] sizeWithAttributes:labelAttributes];
            if (labelSize.width + 30 >= viewWidth)
                viewWidth = labelSize.width + 30;
        }
        
        [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
        self.modalInPopover = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.preferredContentSize.width, self.preferredContentSize.height)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBounces:NO];
    [_tableView setSeparatorColor:[UIColor clearColor]];
    
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return transaction.social.likesCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LIKE_CELL_HEIGHT;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *currentLike = transaction.social.likes[indexPath.row];

    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setUserInteractionEnabled:NO];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"@%@", currentLike[@"nick"]]];
    [cell.textLabel setFont:[UIFont customContentRegular:LIKE_TEXT_HEIGHT]];
    CGRectSetX(cell.textLabel.frame, 10);
    
    return cell;
}

@end
