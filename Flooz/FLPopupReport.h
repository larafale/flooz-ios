//
//  FLPopupReport.h
//  Flooz
//
//  Created by Olivier on 11/21/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPopupReport : UIView<UITextViewDelegate> {
    UIView *background;
}


@property (nonatomic, retain) FLReport *report;

- (id)initWithReport:(FLReport *)rep;
- (void)show;

@end
