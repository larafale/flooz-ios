//
//  AddressBookController.m
//  Flooz
//
//  Created by Olive on 1/22/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "AddressBookController.h"
#import "MZFormSheetController.h"

@interface AddressBookController () {
    BOOL pickerMode;
}

@property (nonatomic, strong) UIBarButtonItem *addItem;
@property (nonatomic, strong) MZFormSheetController *formSheet;

@property (nonatomic, weak) id<AddressBookPickerDelegate> delegate;

@end

@implementation AddressBookController

- (id)init {
    self = [super init];
    if (self) {
        pickerMode = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"SETTINGS_ADDRESS", nil);

    self.addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didAddButtonClick)];
    
    self.navigationItem.rightBarButtonItem = self.addItem;
}

- (void)didAddButtonClick {
    AddressBookFormController *controller = [AddressBookFormController new];
    
    self.formSheet = [[MZFormSheetController alloc] initWithViewController:controller];
    self.formSheet.presentedFormSheetSize = controller.preferredContentSize;
    self.formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    self.formSheet.shadowRadius = 2.0;
    self.formSheet.shadowOpacity = 0.3;
    self.formSheet.shouldDismissOnBackgroundViewTap = YES;
    self.formSheet.shouldCenterVertically = YES;
    self.formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsMoveAboveKeyboard;
    
    [self mz_presentFormSheetController:_formSheet animated:YES completionHandler:nil];
}

- (void)setPickerMode:(id<AddressBookPickerDelegate>)delegate {
    self.delegate = delegate;
    pickerMode = YES;
}

@end
