//
//  FirstLaunchContentViewController.m
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FirstLaunchContentViewController.h"
#import "FLStartButton.h"
#import "FLStartItem.h"

#import "AppDelegate.h"
#import "FLKeyboardView.h"
#import "FLHomeTextField.h"

@interface FirstLaunchContentViewController ()
{
    CGFloat sizePicto;
    CGFloat ratioiPhones;
    
    //Screen 2
    UIImageView *logo;
    NSMutableDictionary *phone;
    
    FLHomeTextField *phoneField;
    FLKeyboardView *inputView;
}

@end

@implementation FirstLaunchContentViewController

- (void)loadView {
    [super loadView];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    CGRect frame    = [[UIScreen mainScreen] bounds];
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    //[self.view setFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight() - STATUSBAR_HEIGHT - NAVBAR_HEIGHT)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sizePicto = 100.0f;
    ratioiPhones = 1.0f;
    if (PPScreenHeight() < 568) {
        ratioiPhones = 1.2f;
        sizePicto = sizePicto / ratioiPhones;
    }
    
	[self setContent];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	if ([self.delegate respondsToSelector:@selector(firstLaunchContentViewControllerDidDAppear:)]) {
		[self.delegate firstLaunchContentViewControllerDidDAppear:self];
	}
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setContent
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT + 20 / ratioiPhones, CGRectGetWidth(self.view.frame), 50 / ratioiPhones)];
    label.font = [UIFont customTitleExtraLight:28];
    label.textColor = [UIColor customBlue];
    label.textAlignment = NSTextAlignmentCenter;
    
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2 - 25.0f, CGRectGetMaxY(label.frame) + 15.0f / ratioiPhones, 50.0f, 1.0f)];
    [bar setBackgroundColor:[UIColor customBlue]];
    
    switch (_pageIndex) {
		case 0: {
            [self.view addSubview:label];
            [self.view addSubview:bar];
            label.text = NSLocalizedString(@"SIGNUP_HEAD_TITLE", @"");
            
            UIView *item1 = [self placePictoAndText:@"friend.png" title:@"SIGNUP_VIEW_1_TITLE_1" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_1" underView:bar];
            UIView *item2 = [self placePictoAndText:@"earth.png" title:@"SIGNUP_VIEW_1_TITLE_2" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_2" underView:item1];
            [self placePictoAndText:@"user.png" title:@"SIGNUP_VIEW_1_TITLE_3" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_3" underView:item2];
            
            FLStartButton *startButton  = [[FLStartButton alloc] initWithFrame:CGRectMake(30, PPScreenHeight() - 60 / ratioiPhones, 180, 44) title:NSLocalizedString(@"SIGNUP_VIEW_1_BUTTON", @"")];
            [startButton setOrigin:CGPointMake(PPScreenWidth()/2 - startButton.frame.size.width/2, PPScreenHeight() - startButton.frame.size.height - 28 / ratioiPhones)];
            [startButton addTarget:self action:@selector(goToNextPage:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:startButton];
        }
            break;
		case 1: {
            [self.view addSubview:label];
            [self.view addSubview:bar];
            label.text = NSLocalizedString(@"SIGNUP_HEAD_TITLE_2", @"");
            
            UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(11, STATUSBAR_HEIGHT + 20 / ratioiPhones, 30, 30)];
            [backButton setImage:[UIImage imageNamed:@"navbar-cross"] forState:UIControlStateNormal];
            [backButton setCenter:CGPointMake(26, CGRectGetMidY(label.frame) + 1)];
            [backButton addTarget:self action:@selector(goToPreviousPage:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:backButton];
            
            UIView *item1 = [self placePictoAndText:@"friend.png" title:@"SIGNUP_VIEW_2_TITLE_1" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_1" underView:bar];
            UIView *item2 = [self placePictoAndText:@"earth.png" title:@"SIGNUP_VIEW_2_TITLE_2" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_2" underView:item1];
            [self placePictoAndText:@"user.png" title:@"SIGNUP_VIEW_2_TITLE_3" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_3" underView:item2];
            
            FLStartButton *startButton  = [[FLStartButton alloc] initWithFrame:CGRectMake(30, PPScreenHeight() - 60 / ratioiPhones, 220, 44) title:NSLocalizedString(@"SIGNUP_VIEW_2_BUTTON", @"")];
            [startButton setOrigin:CGPointMake(PPScreenWidth()/2 - startButton.frame.size.width/2, PPScreenHeight() - startButton.frame.size.height - 28 / ratioiPhones)];
            [startButton addTarget:self action:@selector(goToNextPage:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:startButton];
        }
            break;
        case 2: {
            
            UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(11, STATUSBAR_HEIGHT + 20 / ratioiPhones, 30, 30)];
            [backButton setImage:[UIImage imageNamed:@"navbar-cross"] forState:UIControlStateNormal];
            [backButton setCenter:CGPointMake(26, CGRectGetMidY(label.frame) + 1)];
            [backButton addTarget:self action:@selector(goToPreviousPage:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:backButton];
            
            phone = [NSMutableDictionary new];
            logo = [UIImageView imageNamed:@"home-logo"];
            CGRectSetWidthHeight(logo.frame, 105, 105);
            CGRectSetXY(logo.frame, (SCREEN_WIDTH - logo.frame.size.width) / 2., 60);
            [self.view addSubview:logo];
            
            phoneField = [[FLHomeTextField alloc] initWithPlaceholder:@"06 ou code" for:phone key:@"phone" position:CGPointMake(20, 200)];
            
            if(SCREEN_HEIGHT < 500){
                CGRectSetXY(phoneField.frame, (SCREEN_WIDTH - phoneField.frame.size.width) / 2., CGRectGetMaxY(logo.frame) + 5);
            }
            else{
                CGRectSetXY(phoneField.frame, (SCREEN_WIDTH - phoneField.frame.size.width) / 2., CGRectGetMaxY(logo.frame) + 35);
            }
            [phoneField addForNextClickTarget:self action:@selector(didConnectTouch)];
            
            [self.view addSubview:phoneField];
            
            inputView = [FLKeyboardView new];
            inputView.textField = phoneField.textfield;
            phoneField.textfield.inputView = inputView;
        }
        default: {
            label.text = [NSString stringWithFormat:@"%d", (int)_pageIndex];
        }
    }
}

- (UIView *)placePictoAndText:(NSString *)pictoName title:(NSString *)title subTitle:(NSString *)subTitle underView:(UIView *)view {
    FLStartItem *item = [FLStartItem newWithTitle:@"" imageImageName:pictoName contentText:@"coucou" andSize:sizePicto];
    [item setSize:CGSizeMake(sizePicto, sizePicto)];
    [item setOrigin:CGPointMake(10, CGRectGetMaxY(view.frame) + 15 / ratioiPhones)];
    [self.view addSubview:item];
    
    [self placeTextBesidePicto:item
                     titleText:NSLocalizedString(title, @"")
                  subtitleText:NSLocalizedString(subTitle, @"")];
    
    return item;
}

- (void)placeTextBesidePicto:(UIView *)picto titleText:(NSString *)titleText subtitleText:(NSString *)subText {
    UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(picto.frame), CGRectGetMinY(picto.frame), PPScreenWidth() - CGRectGetMaxX(picto.frame) - 15, CGRectGetHeight(picto.frame))];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(textView.frame), 40)];
    [titleLabel setFont:[UIFont fontWithName:titleLabel.font.fontName size:12]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:titleText];
    [titleLabel setNumberOfLines:0];
    [titleLabel sizeToFit];
    [textView addSubview:titleLabel];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(titleLabel.frame), CGRectGetHeight(titleLabel.frame) + 5.0f / ratioiPhones, CGRectGetWidth(textView.frame), CGRectGetHeight(textView.frame) - titleLabel.frame.size.height)];
    [subtitleLabel setFont:[UIFont fontWithName:titleLabel.font.fontName size:11]];
    [subtitleLabel setTextColor:[UIColor lightGrayColor]];
    [subtitleLabel setText:subText];
    [subtitleLabel setNumberOfLines:0];
    [subtitleLabel sizeToFit];
    [textView addSubview:subtitleLabel];
    
    [textView setSize:CGSizeMake(CGRectGetWidth(textView.frame), CGRectGetHeight(titleLabel.frame) + CGRectGetHeight(subtitleLabel.frame) + 5.0f / ratioiPhones)];
    [textView setCenter:CGPointMake(CGRectGetMidX(textView.frame), CGRectGetMidY(picto.frame))];
    
    [self.view addSubview:textView];
}


- (void)didConnectTouch
{
    [[self view] endEditing:YES];
    
    if(phone[@"phone"] && ![phone[@"phone"] isBlank]){
        [inputView setKeyboardValidateWithTarget:self action:@selector(didConnectTouch)];
        
        [[Flooz sharedInstance] showLoadView];
        [appDelegate clearSavedViewController];
        [[Flooz sharedInstance] loginWithPhone:phone[@"phone"]];
    }
}

#pragma mark - button methods
- (void) goToNextPage:(id)sender {
    //FLStartButton *button = (FLStartButton *)sender;
    if ([self.delegate respondsToSelector:@selector(goToNextPage:)]) {
		[self.delegate goToNextPage:_pageIndex];
	}
}
- (void) goToPreviousPage:(id)sender {
    //FLStartButton *button = (FLStartButton *)sender;
    if ([self.delegate respondsToSelector:@selector(goToPreviousPage:)]) {
		[self.delegate goToPreviousPage:_pageIndex];
	}
}

@end
