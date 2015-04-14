//
//  FLTutoPopoverViewController.m
//  Flooz
//
//  Created by Epitech on 2/25/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FLTutoPopoverViewController.h"

@implementation FLTutoPopoverViewController {
    void (^btnAction)(FLTutoPopoverViewController* viewController);
    
    CGFloat viewHeight;
    CGFloat viewWidth;
    CGFloat viewMargin;
}

@synthesize titleString;
@synthesize msgString;
@synthesize btnString;
@synthesize stepNumber;

- (id)initWithTitle:(NSString*)title message:(NSString*)msg {
    return [self initWithTitle:title message:msg step:nil button:nil action:nil];
}

- (id)initWithTitle:(NSString*)title message:(NSString*)msg step:(NSNumber*)step {
    return [self initWithTitle:title message:msg step:step button:nil action:nil];
}

- (id)initWithTitle:(NSString*)title message:(NSString*)msg button:(NSString*)buttonText action:(void (^)(FLTutoPopoverViewController* viewController))action {
    return [self initWithTitle:title message:msg step:nil button:buttonText action:action];
}

- (id)initWithTitle:(NSString*)title message:(NSString*)msg step:(NSNumber*)step button:(NSString*)buttonText action:(void (^)(FLTutoPopoverViewController* viewController))action {
    self = [super init];
    if (self) {
        titleString = title;
        msgString = msg;
        stepNumber = step;
        btnString = buttonText;
        btnAction = action;
        
        viewMargin = 15;
        viewWidth = 190;
        
        viewHeight = 0;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont customContentBold:14]};
        CGRect rect = [[titleString uppercaseString] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];

        if (rect.size.width + viewMargin / 2 + 21 > viewWidth)
            viewWidth = rect.size.width + viewMargin / 2 + 21;
        
        if (stepNumber || titleString) {
            viewHeight += 20 + viewMargin;
        }
        
        if (msgString) {
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont customContentRegular:14]};
            CGRect rect = [msgString boundingRectWithSize:CGSizeMake(viewWidth - 5, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
            viewHeight += rect.size.height;
        }
        
        if (btnString)
            viewHeight += viewMargin + 26;
        
        [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
        self.modalInPopover = NO;
    }
    return self;
}

- (void)viewDidLoad {
    CGFloat offsetY = 0;
    CGFloat offsetX = 0;
    
    [self.view setBackgroundColor:[UIColor customBlue]];
    
    if (stepNumber) {
        self.popoverStep = [[UILabel alloc] initWithFrame:CGRectMake(offsetX + 1, offsetY + 1, 20, 20)];
        [self.popoverStep setText:[NSString stringWithFormat:@"%@", stepNumber]];
        [self.popoverStep setFont:[UIFont customContentBold:16]];
        [self.popoverStep setTextColor:[UIColor whiteColor]];
        [self.popoverStep setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:self.popoverStep];
        
        [self.popoverStep.layer setMasksToBounds:NO];
        [self.popoverStep.layer setCornerRadius:10.0f];
        [self.popoverStep.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.popoverStep.layer setBorderWidth:1];
        offsetX += viewMargin / 2 + CGRectGetWidth(self.popoverStep.frame);
    }
    
    if (titleString) {
        self.popoverTitle = [[UILabel alloc] initWithText:[titleString uppercaseString] textColor:[UIColor whiteColor] font:[UIFont customContentBold:14]];
        CGRectSetPosition(self.popoverTitle.frame, offsetX, offsetY + 4);
        [self.view addSubview:self.popoverTitle];
    }
    
    if (stepNumber || titleString)
        offsetY += viewMargin + 5 + (self.popoverTitle ? CGRectGetHeight(self.popoverTitle.frame) : CGRectGetHeight(self.popoverStep.frame));
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY - 10, viewWidth, 1)];
    [separator setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:separator];
    
    offsetX = 0;
    
    if (msgString) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont customContentRegular:14]};
        CGRect rect = [msgString boundingRectWithSize:CGSizeMake(viewWidth - 5, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
        rect.origin.x = offsetX + 1;
        rect.origin.y = offsetY;
        
        self.popoverMessage = [[UILabel alloc] initWithFrame:rect];
        [self.popoverMessage setText:msgString];
        [self.popoverMessage setTextColor:[UIColor whiteColor]];
        [self.popoverMessage setNumberOfLines:0];
        [self.popoverMessage setLineBreakMode:NSLineBreakByWordWrapping];
        [self.popoverMessage setFont:[UIFont customContentRegular:14]];
        
        [self.view addSubview:self.popoverMessage];
        
        offsetY += CGRectGetHeight(self.popoverMessage.frame) + viewMargin;
    }
    
    if (btnString) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont customContentBold:15]};
        CGRect rect = [btnString boundingRectWithSize:CGSizeMake(viewWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];

        self.popoverButton = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, rect.size.width + 10, 25)];
        [self.popoverButton setTitle:btnString forState:UIControlStateNormal];
        [self.popoverButton setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
        [self.popoverButton.titleLabel setFont:[UIFont customContentRegular:15]];
        [self.popoverButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.popoverButton setBackgroundColor:[UIColor whiteColor]];
        
        [self.popoverButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self.popoverButton.layer setMasksToBounds:NO];
        [self.popoverButton.layer setCornerRadius:5.0f];
        [self.popoverButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.popoverButton.layer setBorderWidth:1];

        CGRectSetX(self.popoverButton.frame, viewWidth - CGRectGetWidth(self.popoverButton.frame) - 1);
        [self.view addSubview:self.popoverButton];
    }
}

- (void)buttonClick {
    btnAction(self);
}

@end
