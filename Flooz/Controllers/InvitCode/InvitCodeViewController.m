//
//  InvitCodeViewController.m
//  Flooz
//
//  Created by Jonathan on 18/07/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "InvitCodeViewController.h"

@interface InvitCodeViewController ()

@end

@implementation InvitCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_INVIT_CODE", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    {
        _textLabel.text = NSLocalizedString(@"INVITE_CODE_TEXT", nil);
        
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont customContentRegular:16];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    {
        _contentView.backgroundColor = [UIColor customBackgroundHeader];
        _contentView.layer.borderWidth = 1;
        _contentView.layer.borderColor = [UIColor customSeparator].CGColor;
        _contentView.layer.cornerRadius = 3;
    }
    
    {
        _contentTextLabel.text = NSLocalizedString(@"INVITE_CODE_CODE", nil);
        
        _contentTextLabel.font = [UIFont customContentRegular:16];
        _contentTextLabel.textColor = [UIColor customPlaceholder];
        _contentTextLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    {
        _contentCodeLabel.text = [[[Flooz sharedInstance] currentUser] invitCode];
        
        _contentCodeLabel.font = [UIFont customTitleExtraLight:30];
        _contentCodeLabel.textColor = [UIColor whiteColor];
        _contentCodeLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    {
        _shareButton.backgroundColor = [UIColor customBlue];
        [_shareButton setTitle:NSLocalizedString(@"INVITE_CODE_SHARE", nil) forState:UIControlStateNormal];
        [_shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _shareButton.titleLabel.font = [UIFont customContentRegular:15];
        
        [_shareButton addTarget:self action:@selector(didShareButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didShareButtonTouch
{
    NSArray *objectToShare = @[_contentCodeLabel.text];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectToShare applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:nil];
}

@end
