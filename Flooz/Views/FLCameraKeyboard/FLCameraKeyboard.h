//
//  FLCameraKeyboard.h
//  Flooz
//
//  Created by Arnaud on 2014-09-09.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#define degreesToRadians(degrees) ((degrees) / 180.0 * M_PI)

@protocol FLCameraKeyboardDelegate;

@interface FLCameraKeyboard : UIView <AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	__weak UIViewController *currentController;
}

@property (weak, nonatomic) UIViewController <FLCameraKeyboardDelegate> *delegate;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

- (id)initWithController:(UIViewController *)controller height:(CGFloat)height delegate:(id)delegate;
- (void)startCamera;
- (void)stopCamera;
- (void)setCameraHeight:(CGFloat)height;

@end

@protocol FLCameraKeyboardDelegate <NSObject>

- (void)rotateImageWithRadians:(CGFloat)radian imageRotate:(UIImage *)rotateImage andImage:(UIImage *)image;
- (void)goToFullScreen:(BOOL)fullScreen;
- (void)presentCameraRoll:(UIImagePickerController *)cameraRoll;
- (void)growCameraToHeight:(CGFloat)he;

@end
