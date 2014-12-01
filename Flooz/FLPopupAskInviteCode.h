//
//  FLPopupAskInviteCode.h
//  Flooz
//
//  Created by Epitech on 11/4/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPopupAskInviteCode : UIView {
    UIView *background;
}

- (id)initWithUser:(NSMutableDictionary *)user andCompletionBlock:(void (^)())completionBlock;

- (void)show;

@end
