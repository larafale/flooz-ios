//
//  TutoViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-10-09.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TutoPageWelcome = 0,
    TutoPageTimeline,
    TutoPageFlooz
} TutoPage;

@interface TutoViewController : GlobalViewController

@property (nonatomic) BOOL hasAlreadySawTuto;
@property (strong, nonatomic) NSString *keyTuto;

- (id)initWithTutoPage:(TutoPage)tutoPage;
- (id)initWithImageNamed:(NSString *)imageNamed;

@end
