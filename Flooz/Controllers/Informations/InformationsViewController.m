//
//  InformationsViewController.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "InformationsViewController.h"

#import "WebViewController.h"

@interface InformationsViewController (){
    NSArray *links;
}

@end

@implementation InformationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_INFORMATIONS", nil);
        
        links = @[
                  @"why",
                  @"terms",
                  @"faq",
                  @"contact"
                  ];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [links count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 69.;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.backgroundColor = [UIColor customBackground];
        cell.textLabel.font = [UIFont customTitleExtraLight:16];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = [UIImageView imageNamed:@"arrow-white-right"];
    }
    
    NSString *link = [links objectAtIndex:indexPath.row];
    cell.textLabel.text = NSLocalizedString([@"INFORMATIONS_" stringByAppendingString:[link uppercaseString]], nil);
    cell.imageView.image = [UIImage imageNamed:[@"informations-" stringByAppendingString:link]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url;
    NSString *link = [links objectAtIndex:indexPath.row];
    NSString *title = NSLocalizedString([@"INFORMATIONS_" stringByAppendingString:[link uppercaseString]], nil);
    
    switch (indexPath.row) {
        case 0:
            url = @"n/security";
            break;
        case 1:
            url = @"n/cgu";
            break;
        case 2:
            url = @"n/faq";
            break;
        case 3:
            url = @"n/contact";
            break;
        default:
            break;
    }
    
    WebViewController *controller = [WebViewController new];
    [controller setUrl:[@"https://www.flooz.me/" stringByAppendingString:url]];
    controller.title = title;
    [[self navigationController] pushViewController:controller animated:YES];
}

@end
