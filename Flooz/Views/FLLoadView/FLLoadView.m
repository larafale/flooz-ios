//
//  FLLoadView.m
//  Flooz
//
//  Created by jonathan on 1/16/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLLoadView.h"

#import "AppDelegate.h"

@implementation FLLoadView

+ (void)execute:(BOOL (^)())block completion:(void (^)(BOOL success))completion
{
    return [self execute:block completion:completion lockScreen:NO];
}

+ (void)execute:(BOOL (^)())block completion:(void (^)(BOOL success))completion lockScreen:(BOOL)lockScreen
{
    FLLoadView *loadView = [FLLoadView new];
    [loadView execute:block completion:completion lockScreen:lockScreen];
}

- (id)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor customBackgroundHeader:0.5];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView startAnimating];
        activityIndicatorView.center = self.center;
        [self addSubview:activityIndicatorView];
    }
    return self;
}

- (void)show
{
    [appDelegate.window addSubview:self];
}

- (void)hide
{
    [self removeFromSuperview];
}

- (void)execute:(BOOL (^)())block completion:(void (^)(BOOL success))completion lockScreen:(BOOL)lockScreen
{
    if(lockScreen){
        [self show];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = block();
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(lockScreen){
                [self hide];
            }
            if(completion){
                completion(success);
            }
        });
    });
}

@end
