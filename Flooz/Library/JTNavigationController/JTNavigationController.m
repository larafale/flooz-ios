//
//  JTNavigationController.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "JTNavigationController.h"

@interface JTNavigationController (){
    UIBarButtonItem *backItem;
}

@end

@implementation JTNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
        [self customAppearence];
    }
    return self;
}

- (void)customAppearence
{
    if(IS_IOS7){
        [[UINavigationBar appearance] setBarTintColor:[UIColor customBackgroundHeader]];
        self.navigationBar.translucent = NO;
        
        NSDictionary *attributes = @{
                                     NSForegroundColorAttributeName: [UIColor customBlue],
                                     NSFontAttributeName: [UIFont customTitleExtraLight:28]
                                     };
        
        [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    }
    else{
//        [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//        [[UINavigationBar appearance] setBackgroundColor:[UIColor customBackgroundHeader]];
//        
//        NSDictionary *attributes = @{
//                                     UITextAttributeTextColor: [UIColor customBlue],
//                                     UITextAttributeFont: [UIFont customTitleExtraLight:28]
//                                     };
//        
//        [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    }
    
    backItem = [UIBarButtonItem createBackButtonWithTarget:self action:@selector(popVC)];
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), SCREEN_WIDTH, 1)];
    borderView.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:.1];
    [self.navigationBar addSubview:borderView];
    
    self.navigationBar.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.navigationBar.layer.shadowOpacity = .5;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.navigationItem.leftBarButtonItem = backItem;
}

- (void) popVC{
    [self popViewControllerAnimated:YES];
}

@end
