//
//  ScannerViewController.m
//  Flooz
//
//  Created by Olivier on 4/21/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "ScannerViewController.h"
#import "FLScannerOverlay.h"

@interface ScannerViewController ()

@property (nonatomic) int errorLoop;
@property (nonatomic) BOOL handleError;
@property (nonatomic, retain) NSTimer *errorTimeout;
@property (nonatomic, retain) UIView *videoView;
@property (nonatomic, retain) FLScannerOverlay *scanView;
@property (nonatomic, retain) UIView *focusView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;

@end

@implementation ScannerViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"ACCOUNT_BUTTON_QRCODE", nil);
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    _errorLoop = 0;
    _handleError = YES;
    
    _videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    _scanView = [[FLScannerOverlay alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    
    [_mainBody addSubview:_videoView];
    [_mainBody addSubview:_scanView];
    
    float focusViewSize = CGRectGetWidth(_mainBody.frame) - 2 * 50;
    
    _focusView = [[UIView alloc] initWithFrame:CGRectMake(50, CGRectGetHeight(_mainBody.frame) / 2 - focusViewSize / 2, focusViewSize, focusViewSize)];
    [_focusView.layer setMasksToBounds:YES];
    _focusView.layer.borderColor = [UIColor customBlue].CGColor;
    _focusView.layer.borderWidth = 2;
    
    [_mainBody addSubview:_focusView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startReading];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopReading];
    
    if (_errorTimeout) {
        [_errorTimeout invalidate];
        _errorTimeout = nil;
    }
}

- (void)timerUpdate {
    ++_errorLoop;
    if (_errorLoop >= 4) {
        _focusView.layer.borderColor = [UIColor customBlue].CGColor;
        _errorLoop = 0;
        [_errorTimeout invalidate];
        _errorTimeout = nil;
        _handleError = YES;
    }
}

- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:_captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("scanQueue", NULL);
    [_captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [_captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_videoView.layer.bounds];
    [_videoView.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
    
    return YES;
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

- (BOOL)isAllDigits:(NSString *)string
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [string rangeOfCharacterFromSet:nonNumbers];
    return r.location == NSNotFound;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            NSString *codeValue = [metadataObj stringValue];
            
            if ([codeValue rangeOfString:@"flooz://"].location != NSNotFound) {
                NSString *code = [codeValue stringByReplacingOccurrencesOfString:@"flooz://" withString:@""];
                if ([self isAllDigits:code]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _focusView.layer.borderColor = [UIColor customGreen].CGColor;
                        [[Flooz sharedInstance] showLoadView];
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    });
                } else {
                    [self handleScanError];
                }
            } else {
                [self handleScanError];
            }
        }
    }
}

-(void)handleScanError {
    dispatch_async(dispatch_get_main_queue(), ^{
        _focusView.layer.borderColor = [UIColor customRed].CGColor;
        if (_handleError) {
            [appDelegate displayMessage:@"QR Code invalide" content:@"Veuillez scanner un QR Code Flooz." style:FLAlertViewStyleError time:@3 delay:@0];
            if (_errorTimeout) {
                [_errorTimeout invalidate];
                _errorTimeout = nil;
            }
            _errorLoop = 0;
            _errorTimeout = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
            _handleError = NO;
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    });
}

@end
