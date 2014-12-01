//
//  InformationsViewController.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "InformationsViewController.h"

#import "WebViewController.h"

@interface InformationsViewController () {
	NSArray *links;
    UITableView *_tableView;
}

@end

@implementation InformationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [UITableView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setBackgroundColor:[UIColor customBackgroundHeader]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [_mainBody addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [links count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 69.;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

		cell.backgroundColor = [UIColor customBackgroundHeader];
		cell.textLabel.font = [UIFont customTitleExtraLight:16];
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryView = [UIImageView imageNamed:@"arrow-white-right"];
	}

	NSString *link = [links objectAtIndex:indexPath.row];
	cell.textLabel.text = NSLocalizedString([@"INFORMATIONS_" stringByAppendingString:[link uppercaseString]], nil);
	cell.imageView.image = [UIImage imageNamed:[@"informations-" stringByAppendingString : link]];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *url;
	NSString *link = [links objectAtIndex:indexPath.row];
	NSString *title = NSLocalizedString([@"INFORMATIONS_" stringByAppendingString:[link uppercaseString]], nil);

	switch (indexPath.row) {
		case 0:
			url = @"security?layout=webview";
			break;

		case 1:
			url = @"cgu?layout=webview";
			break;

		case 2:
			url = @"faq?layout=webview";
			break;

		case 3:
			url = @"contact?layout=webview";
			break;

		default:
			break;
	}

	WebViewController *controller = [WebViewController new];
	[controller setUrl:[@"https://www.flooz.me/" stringByAppendingString : url]];
    controller.title = title;
	[[self navigationController] pushViewController:controller animated:YES];
}

@end
