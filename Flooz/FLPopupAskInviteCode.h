//
//  FLPopupAskInviteCode.h
//  Flooz
//
//  Created by Olivier on 11/4/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPopupAskInviteCode : UIView {
    UIView *background;
}

- (id)initWithUser:(NSMutableDictionary *)user andCompletionBlock:(void (^)())completionBlock;

- (void)show;

@end
