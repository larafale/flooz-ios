//
//  FLCameraKeyboard.m
//  Flooz
//
//  Created by Arnaud on 2014-09-09.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLCameraKeyboard.h"

@implementation FLCameraKeyboard {
	UIView *cameraView;
	AVCaptureSession *captureSession;

	UIButton *shooterButton;
	UIButton *cameraRollButton;
	UIButton *switchButton;

	CGFloat heightCamera;

	CGFloat heightImageToCapture;
    
    CGFloat heightBase;
    CGFloat yStart;
}

- (id)initWithController:(UIViewController *)controller height:(CGFloat)height delegate:(id)delegate {
	heightCamera = height;
    heightBase = height;
	heightImageToCapture = heightCamera;
	self = [super initWithFrame:CGRectMake(0, 0, PPScreenWidth(), height)];
	if (self) {
		self.backgroundColor = [UIColor customBackground];

		currentController = controller;
		_delegate = delegate;

		BOOL hasCamera = ([[AVCaptureDevice devices] count] > 0);
		if (hasCamera) {
			[self createMainCamera];
			[self createShooterButton];
			[self createCameraRollButton];
			[self createSwitchButton];

			[self deviceOrientationDidChange:nil];

			[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

			UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPanGesture:)];
			panGesture.delegate = self;
            [self addGestureRecognizer:panGesture];

			UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUp:)];
			swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
//			[self addGestureRecognizer:swipeUp];

			UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown:)];
			swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
//			[self addGestureRecognizer:swipeDown];
		}
		else {
			[self cameraRoll];
		}
	}
	return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint velocity = [panGestureRecognizer velocityInView:self];
    return fabs(velocity.y) > fabs(velocity.x);
}

- (void)respondToPanGesture:(UIPanGestureRecognizer *)recognizer {
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan: {
			CGPoint translation = [recognizer translationInView:self];
            yStart = translation.y;
		}
		break;

		case UIGestureRecognizerStateChanged: {
			CGPoint translation = [recognizer translationInView:self];
			CGFloat height = heightBase - translation.y;
			[self.delegate growCameraToHeight:height];
		}
		break;

		case UIGestureRecognizerStateEnded: {
			CGPoint velocity = [recognizer velocityInView:self];

			if (velocity.y > 0) {
				[self.delegate goToFullScreen:NO];
				heightBase = heightCamera;
			}
			else {
				[self.delegate goToFullScreen:YES];
				heightBase = PPScreenHeight();
			}
		}
		break;

		default:
			break;
	}
}

- (void)swipeUp:(UISwipeGestureRecognizer *)gestureRecognizer {
	CGFloat height = PPScreenHeight(); // - 90 - PPStatusBarHeight();
	if (CGRectGetHeight(_captureVideoPreviewLayer.frame) < height) {
		[self.delegate goToFullScreen:YES];
//        [self setCameraHeight:height];
	}
}

- (void)swipeDown:(UISwipeGestureRecognizer *)gestureRecognizer {
	if (CGRectGetHeight(_captureVideoPreviewLayer.frame) > heightCamera) {
		[self.delegate goToFullScreen:NO];
//        [self setCameraHeight:heightCamera];
	}
}

- (void)setCameraHeight:(CGFloat)height {
    heightImageToCapture = height;
//    CGFloat yVideoFrame = - (PPScreenHeight() - height) / 2.0f;
//    CGRect f = _captureVideoPreviewLayer.frame;
//    CGRectSetY(f, yVideoFrame);
    CGRect bounds = self.layer.bounds;
    _captureVideoPreviewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    [self replaceButtons];
}

- (void)replaceButtons {
	CGRectSetY(shooterButton.frame, heightImageToCapture - 80.0);
	CGRectSetY(cameraRollButton.frame, heightImageToCapture - 65.0);
	CGRectSetY(switchButton.frame, heightImageToCapture - 65.0);
}

- (void)createMainCamera {
	if (!captureSession) {
		captureSession = [[AVCaptureSession alloc] init];
	}

	captureSession.sessionPreset = AVCaptureSessionPresetHigh;

	_captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
	[_captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
	_captureVideoPreviewLayer.frame = CGRectMake(0, - (PPScreenHeight() - 216) / 2.0f, PPScreenWidth(), PPScreenHeight());
	[self.layer addSublayer:_captureVideoPreviewLayer];

	UIView *view = self;
	CALayer *viewLayer = [view layer];
	[viewLayer setMasksToBounds:YES];

    CGRect bounds = [view bounds];
    _captureVideoPreviewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

	_stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
	[_stillImageOutput setOutputSettings:outputSettings];

	[captureSession addOutput:_stillImageOutput];

	[self switchCamera];

	AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
	if (!captureInput) {
		return;
	}
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	[captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
	NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
	NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
	[captureOutput setVideoSettings:videoSettings];

	cameraView = view;
}

- (void)switchCamera {
	[captureSession beginConfiguration];
	AVCaptureInput *currentCameraInput;
	if (captureSession.inputs.count) {
		currentCameraInput = [captureSession.inputs objectAtIndex:0];
		[captureSession removeInput:currentCameraInput];
	}

	AVCaptureDevice *newCamera = nil;
	if (((AVCaptureDeviceInput *)currentCameraInput).device.position == AVCaptureDevicePositionBack) {
		newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
	}
	else {
		newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
	}

	//Add input to session
	AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
	[captureSession addInput:newVideoInput];

	//Commit all the configuration changes at once
	[captureSession commitConfiguration];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		if ([device position] == position) return device;
	}
	return nil;
}

- (void)createShooterButton {
	shooterButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 80.0) / 2.0f, CGRectGetHeight(self.frame) - 80.0, 80, 80)];
	[shooterButton setImage:[UIImage imageNamed:@"camera-plus"] forState:UIControlStateNormal];
	[shooterButton addTarget:self action:@selector(captureStillImage) forControlEvents:UIControlEventTouchUpInside];
	[shooterButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	[self addSubview:shooterButton];
}

- (void)createCameraRollButton {
	cameraRollButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(self.frame) - 65.0, 60, 60)];
	[cameraRollButton setImage:[UIImage imageNamed:@"camera-album"] forState:UIControlStateNormal];
	[cameraRollButton addTarget:self action:@selector(cameraRoll) forControlEvents:UIControlEventTouchUpInside];
	[cameraRollButton setImageEdgeInsets:UIEdgeInsetsMake(20, 18, 18, 18)];
	[self addSubview:cameraRollButton];
}

- (void)createSwitchButton {
	switchButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 60.0, CGRectGetHeight(self.frame) - 65.0, 60, 60)];
	[switchButton setImage:[UIImage imageNamed:@"camera-switch"] forState:UIControlStateNormal];
	[switchButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
	[switchButton setImageEdgeInsets:UIEdgeInsetsMake(20, 18, 18, 18)];
	[self addSubview:switchButton];
}

- (void)captureStillImage {
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in[[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in[connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
			break;
		}
	}

	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
	                                                     completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
	    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
	    UIImage *image = [[UIImage alloc] initWithData:imageData];
	    [self processImage:image];
	}];
}

- (void)processImage:(UIImage *)image {  // process captured image, crop, resize and rotate
    CGSize imageSize = image.size;
    CGFloat screenHeight = PPScreenHeight();
    CGFloat startY = CGRectGetMinY(_captureVideoPreviewLayer.frame);
    
    if (startY < 0)
        startY = (imageSize.height * startY) / screenHeight;
    
    UIGraphicsBeginImageContext(CGSizeMake(imageSize.width, imageSize.height));
	[image drawInRect:CGRectMake(0, startY, imageSize.width, imageSize.height)];
	UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    CGRect cropRect = CGRectMake(0, 0, imageSize.width, (imageSize.height * heightImageToCapture) / screenHeight);
	CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
	UIImage *imageCroped = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);

	CGFloat radianForRotation = degreesToRadians(0);
	UIImage *rotatedImage = imageCroped;

	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIDeviceOrientationLandscapeLeft) {
		if (((AVCaptureDeviceInput *)[captureSession.inputs objectAtIndex:0]).device.position == AVCaptureDevicePositionFront) {
			radianForRotation = degreesToRadians(90);
			rotatedImage = [[UIImage alloc] initWithCGImage:imageCroped.CGImage scale:1.0f orientation:UIImageOrientationRight];
		}
		else {
			radianForRotation = degreesToRadians(-90);
			rotatedImage = [[UIImage alloc] initWithCGImage:imageCroped.CGImage scale:1.0f orientation:UIImageOrientationLeft];
		}
	}
	else if (orientation == UIDeviceOrientationLandscapeRight) {
		if (((AVCaptureDeviceInput *)[captureSession.inputs objectAtIndex:0]).device.position == AVCaptureDevicePositionFront) {
			radianForRotation = degreesToRadians(-90);
			rotatedImage = [[UIImage alloc] initWithCGImage:imageCroped.CGImage scale:1.0f orientation:UIImageOrientationLeft];
		}
		else {
			radianForRotation = degreesToRadians(90);
			rotatedImage = [[UIImage alloc] initWithCGImage:imageCroped.CGImage scale:1.0f orientation:UIImageOrientationRight];
		}
	}
	else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
		radianForRotation = degreesToRadians(180);
		rotatedImage = [[UIImage alloc] initWithCGImage:imageCroped.CGImage scale:1.0f orientation:UIImageOrientationDown];
	}

	[self.delegate rotateImageWithRadians:radianForRotation imageRotate:rotatedImage andImage:imageCroped];
}

- (void)cameraRoll {
	UIImagePickerController *cameraUI = [UIImagePickerController new];
	cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	cameraUI.delegate = self;
    cameraUI.allowsEditing = YES;

	[self.delegate presentCameraRoll:cameraUI];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
	UIImage *resizedImage = [originalImage resize:CGSizeMake(640, 0)];

	[self.delegate rotateImageWithRadians:degreesToRadians(0) imageRotate:resizedImage andImage:resizedImage];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)startCamera {
	[captureSession startRunning];
}

- (void)stopCamera {
	[captureSession stopRunning];
}

#pragma mark - device orientation

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	//Obtain current device orientation
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

	CGFloat radianForRotation = degreesToRadians(0);
	if (orientation == UIDeviceOrientationLandscapeLeft) {
		radianForRotation = degreesToRadians(90);
	}
	else if (orientation == UIDeviceOrientationLandscapeRight) {
		radianForRotation = degreesToRadians(-90);
	}
	else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
		radianForRotation = degreesToRadians(180);
	}
	else {
		radianForRotation = degreesToRadians(0);
	}

	[self rotateButtonsWithRadians:radianForRotation];
}

- (void)rotateButtonsWithRadians:(CGFloat)radians {
	[UIView beginAnimations:@"rotateButtons" context:nil];
	[UIView setAnimationDuration:0.3];
	{
		shooterButton.transform = CGAffineTransformMakeRotation(radians);
		cameraRollButton.transform = CGAffineTransformMakeRotation(radians);
		switchButton.transform = CGAffineTransformMakeRotation(radians);
	}
	[UIView commitAnimations];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
}

@end
