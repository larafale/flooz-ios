//
//  EventCommentView.h
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EventActionViewDelegate.h"

@interface EventCommentsView : UIView<UITextFieldDelegate>{
    CGFloat height;
    __weak UITextField *_textField;
}

@property (weak, nonatomic) FLEvent *event;
@property (weak, nonatomic) id<EventActionViewDelegate> delegate;

@end
