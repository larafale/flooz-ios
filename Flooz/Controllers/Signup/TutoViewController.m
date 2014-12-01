//
//  TutoViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-09.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "TutoViewController.h"

@interface TutoViewController () {
	NSString *_imageNamed;
}

@end

@implementation TutoViewController

- (id)initWithTutoPage:(TutoPage)tutoPage {
	self = [self init];
	if (self) {
        switch (tutoPage) {
            case TutoPageWelcome:
                _keyTuto = kKeyTutoWelcome;
                _imageNamed = @"tuto-welcome";
                break;
                
            case TutoPageTimeline:
                _keyTuto = kKeyTutoTimeline;
                _imageNamed = @"tuto-timeline";
                break;

            case TutoPageFlooz:
                _keyTuto = kKeyTutoFlooz;
				_imageNamed = @"tuto-flooz";
				break;

			default:
				break;
		}
		if (IS_IPHONE4) {
			_imageNamed = [_imageNamed stringByAppendingString:@"-iphone4"];
		}
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:_keyTuto]) {
            _hasAlreadySawTuto = YES;
        }
        else {
            _hasAlreadySawTuto = NO;
        }
	}
	return self;
}

- (id)initWithImageNamed:(NSString *)imageNamed {
	self = [self init];
	if (self) {
		_imageNamed = imageNamed;
		if (IS_IPHONE4) {
			_imageNamed = [_imageNamed stringByAppendingString:@"-iphone4"];
		}
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIButton *tutoImage = [UIButton newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), PPScreenHeight())];
	[tutoImage addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];

	UIImage *image = [UIImage imageNamed:_imageNamed];
	[tutoImage setImage:image forState:UIControlStateNormal];
	[tutoImage setImage:image forState:UIControlStateHighlighted];

	[self.view addSubview:tutoImage];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[Flooz sharedInstance] saveSettingsObject:@YES withKey:_keyTuto];
}

- (void)remove {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler: ^(MZFormSheetController *formSheetController) {
        appDelegate.formSheet = nil;
        if (_keyTuto == kKeyTutoWelcome) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                UIViewController *v = appDelegate.revealSideViewController;
                [appDelegate showTutoPage:TutoPageTimeline inController:v];
            });
        }
    }];
}

@end
