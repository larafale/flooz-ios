//
//  ImagePickerViewController.h
//  Flooz
//
//  Created by Olive on 16/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendAddSearchBarDelegate.h"

@protocol ImagePickerViewControllerDelegate

- (void)image:(NSString *)imageUrl pickedFrom:(UIViewController *)viewController;

@end

@interface ImagePickerViewController : BaseViewController<FriendAddSearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) id<ImagePickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *type;

+ (id)newWithDelegate:(id<ImagePickerViewControllerDelegate>)delegate andType:(NSString *)type;
- (id)initWithDelegate:(id<ImagePickerViewControllerDelegate>)delegate andType:(NSString *)type;

@end