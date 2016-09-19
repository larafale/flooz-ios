//
//  FLLikePopoverViewController.m
//  Flooz
//
//  Created by Olivier on 12/31/14.
//  Copyright (c) 2014 Olivier Mouren. All rights reserved.
//

#import "FLLikePopoverViewController.h"

@interface FLLikePopoverViewController () {
    FLSocial *socialData;
    
    CGFloat viewHeight;
    CGFloat viewWidth;
}

@end

#define LIKE_CELL_HEIGHT 25.0f
#define LIKE_TEXT_HEIGHT 14.0f

@implementation FLLikePopoverViewController

@synthesize tableView;

- (id)initWithSocial:(FLSocial*)social {
    self = [super init];
    if (self) {
        socialData = social;
        
        CGFloat maxHeight = PPScreenHeight() / 3;
        CGFloat totalHeight = LIKE_CELL_HEIGHT * socialData.likesCount;
        
        if (totalHeight <= maxHeight)
            viewHeight = totalHeight;
        else {
            viewHeight = maxHeight;
        }
        
        viewWidth = 0;
        
        NSDictionary *labelAttributes = @{NSFontAttributeName: [UIFont customContentRegular:LIKE_TEXT_HEIGHT]};

        for (NSDictionary *like in socialData.likes) {
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
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.preferredContentSize.width, self.preferredContentSize.height)];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBounces:NO];
    [tableView setSeparatorColor:[UIColor clearColor]];
    
    [self.view addSubview:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return socialData.likesCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LIKE_CELL_HEIGHT;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *currentLike = socialData.likes[indexPath.row];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
        
    [cell.textLabel setText:[NSString stringWithFormat:@"@%@", currentLike[@"nick"]]];
    [cell.textLabel setFont:[UIFont customContentRegular:LIKE_TEXT_HEIGHT]];
    CGRectSetX(cell.textLabel.frame, 10);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate) {
        NSDictionary *currentLike = socialData.likes[indexPath.row];
        FLUser *user = [[FLUser alloc] initWithJSON:currentLike];
        user.userId = currentLike[@"userId"];
        
        [self.delegate didUserClick:user];
    }
}

@end
