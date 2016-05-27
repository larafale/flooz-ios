//
//  CashinCardKYCViewController.m
//  Flooz
//
//  Created by Olive on 10/05/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "CashinCardKYCViewController.h"

#define PADDING_SIDE 20.0f

@interface CashinCardKYCViewController () {
    NSMutableDictionary *_userDic;
    NSMutableDictionary *_sepa;
    
    NSArray *documents;
    NSMutableArray *documentsButton;
    
    NSInteger registerButtonCount;
    NSString *currentDocumentKey;
    
    FLActionButton *_saveButton;
    
    CGFloat height;
}

@end

@implementation CashinCardKYCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hideNavShadow = YES;
    
    if (!self.title || [self.title isBlank])
        self.title = @"Enregistrer ma carte";
    
    [self initWithInfo];
    
    documentsButton = [NSMutableArray new];
    
    UILabel *infosLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIDE, PADDING_SIDE, PPScreenWidth() - 2 * PADDING_SIDE, 0)];
    [infosLabel setText:[Flooz sharedInstance].currentTexts.menu[@"documents"][@"content"]];
    [infosLabel setTextColor:[UIColor whiteColor]];
    [infosLabel setTextAlignment:NSTextAlignmentCenter];
    [infosLabel setFont:[UIFont customContentRegular:15]];
    [infosLabel setNumberOfLines:0];
    [infosLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    [infosLabel setHeightToFit];
    
    [_mainBody addSubview:infosLabel];
    
    UIImageView *cardInfos = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(infosLabel.frame) + PADDING_SIDE, PPScreenWidth() - 2 * PADDING_SIDE, 150)];
    [cardInfos setContentMode:UIViewContentModeScaleAspectFit];
    [cardInfos setImage:[UIImage imageNamed:@"visa_paper"]];
    
    
    [_mainBody addSubview:cardInfos];
    
    height = CGRectGetMaxY(cardInfos.frame) + PADDING_SIDE;
    
    for (NSDictionary *dic in documents) {
        NSString *key = [[dic allKeys] firstObject];
        NSString *value = [[dic allValues] firstObject];
        [self createDocumentsButtonWithKey:key andValue:value];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];    
}

- (void)initWithInfo {
    
    documents = @[
                  @{ @"CREDIT_CARD": @"card" },
                  @{ @"CARD_ID_RECTO": @"cniRecto" },
                  @{ @"CARD_ID_VERSO": @"cniVerso" },
                  @{ @"HOME": @"justificatory" },
                  @{ @"HOME2": @"justificatory2" }
                  ];
    
    registerButtonCount = 0;
}

- (void)createDocumentsButtonWithKey:(NSString *)key andValue:(NSString *)value {
    static int buttonId = 0;
    
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, height, PPScreenWidth() - PADDING_SIDE * 2.0f, 45)];
    [view setTag:50 + buttonId];
    [_mainBody addSubview:view];

    ++buttonId;
    
    height = CGRectGetMaxY(view.frame);
    
    [view addTarget:self action:@selector(didDocumentButtonTouch:) forControlEvents:UIControlEventTouchUpInside];

    view.backgroundColor = [UIColor customBackgroundHeader];
    view.titleLabel.font = [UIFont customTitleExtraLight:16];
    view.titleLabel.textColor = [UIColor whiteColor];
    
    [view setTitle:NSLocalizedString(([NSString stringWithFormat:@"DOCUMENTS_%@", key]), nil) forState:UIControlStateNormal];
    view.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [view setTitleEdgeInsets:UIEdgeInsetsMake(0, 10.0f, 0, 0)];
    
    {
        UIImageView *imageView = [UIImageView imageNamed:@"friends-field-in"];
        if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:value] intValue] == 0){
            imageView = [UIImageView imageNamed:@"document-refused"];
        }
        if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:value] intValue] == 3){
            imageView = [UIImageView imageNamed:@"friends-field-add"];
        }
        [documentsButton addObject:imageView];
        CGRectSetXY(imageView.frame, CGRectGetWidth(view.frame) - CGRectGetWidth(imageView.frame), (CGRectGetHeight(view.frame) - CGRectGetHeight(imageView.frame)) / 2.0f);
        [view addSubview:imageView];
    }
    
    [self createBottomBar:view];
}

- (void)createBottomBar:(UIView *)view {
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(view.frame) - 1.0f, CGRectGetWidth(view.frame), 1.0f)];
    bottomBar.backgroundColor = [UIColor customBackground];
    
    [view addSubview:bottomBar];
}

- (void)didDocumentButtonTouch:(UIView *)sender {
    long buttonId = sender.tag - 50;
    
    currentDocumentKey = [[documents[buttonId] allValues] firstObject];
    [self showImagePicker];
}

#pragma mark - imagePicker

- (void)showImagePicker {
    if ([[[Flooz sharedInstance] currentUser] settings][currentDocumentKey] && ([[[[Flooz sharedInstance] currentUser] checkDocuments][currentDocumentKey] intValue] == 1 || [[[[Flooz sharedInstance] currentUser] checkDocuments][currentDocumentKey] intValue] == 2)) {
        return;
    }
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
        [self createActionSheet];
    }
    else {
        [self createAlertController];
    }
}

- (void)createAlertController {
    
    NSString *message = nil;
    
    if ([currentDocumentKey isEqualToString:@"card"]) {
        message = @"Les 6 premiers et 4 derniers chiffres ainsi que le nom doivent être visibles";
    }
    
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CAMERA", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self displayImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
        }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_ALBUMS", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self displayImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
        }]];
    }
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)createActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [menus addObject:NSLocalizedString(@"GLOBAL_CAMERA", nil)];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [menus addObject:NSLocalizedString(@"GLOBAL_ALBUMS", nil)];
    }
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"GLOBAL_CAMERA", nil)]) {
        [self displayImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"GLOBAL_ALBUMS", nil)]) {
        [self displayImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)displayImagePickerWithType:(UIImagePickerControllerSourceType)type {
    if (type == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (authStatus == AVAuthorizationStatusAuthorized) {
            UIImagePickerController *cameraUI = [UIImagePickerController new];
            cameraUI.sourceType = type;
            cameraUI.delegate = self;
            cameraUI.allowsEditing = YES;
            [self presentViewController:cameraUI animated:YES completion: ^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }];
        } else if (authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted){
                    UIImagePickerController *cameraUI = [UIImagePickerController new];
                    cameraUI.sourceType = type;
                    cameraUI.delegate = self;
                    cameraUI.allowsEditing = YES;
                    [self presentViewController:cameraUI animated:YES completion: ^{
                        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                    }];
                } else {
                    
                }
            }];
        } else {
            UIAlertView* curr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CAMERA_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CAMERA_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
            [curr setTag:125];
            dispatch_async(dispatch_get_main_queue(), ^{
                [curr show];
            });
        }
    } else {
        UIImagePickerController *cameraUI = [UIImagePickerController new];
        cameraUI.sourceType = type;
        cameraUI.delegate = self;
        cameraUI.allowsEditing = YES;
        [self presentViewController:cameraUI animated:YES completion: ^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 125 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if (currentDocumentKey) {
        UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *resizedImage = [originalImage resize:CGSizeMake(640, 0)];
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);
        
        NSString *key = currentDocumentKey;
        
        [picker dismissViewControllerAnimated:YES completion: ^{
            [[Flooz sharedInstance] uploadDocument:imageData field:key success:nil failure:NULL];
            
            NSUInteger index = 0;
            for (NSDictionary * dic in documents) {
                if ([[[dic allValues] firstObject] isEqualToString:currentDocumentKey]) {
                    break;
                }
                index++;
            }
            
            UIImageView *imageView = [documentsButton objectAtIndex:index];
            [imageView setImage:[UIImage imageNamed:@"friends-field-in"]];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
