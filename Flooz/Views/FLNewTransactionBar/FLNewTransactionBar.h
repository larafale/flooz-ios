//
//  FLNewTransactionBar.h
//  Flooz
//
//  Created by Olivier on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import "FLTransaction.h"
#import "WYPopoverController.h"
#import "FLPrivacySelectorViewController.h"
#import "FLPreset.h"

@protocol FLNewTransactionBarDelegate <NSObject>

- (void)presentCamera;
- (void)presentLocation;
- (void)presentImagePicker;
- (void)presentGIFPicker;
- (void)focusDescription;

@end

@interface FLNewTransactionBar : UIView <CLLocationManagerDelegate> {
	SEL actionValidSend;
	SEL actionValidCollect;
    SEL actionValidCharge;
    SEL actionValidParticipation;

	__weak NSMutableDictionary *_dictionary;
	CLLocationManager *locationManager;

	__weak UIViewController *currentController;
}

@property (weak) id <FLNewTransactionBarDelegate> delegate;
@property (nonatomic, retain) UIButton *cameraButton;
@property (nonatomic, retain) UIButton *imageButton;
@property (nonatomic, retain) UIButton *gifButton;
@property (nonatomic, retain) UIButton *textButton;;
@property (nonatomic, retain) UIButton *locationButton;
@property (nonatomic, retain) UIView *paymentButtonsSeparator;
@property (nonatomic, retain) FLActionButton *askButton;
@property (nonatomic, retain) FLActionButton *sendButton;
@property (nonatomic, retain) FLActionButton *collectButton;
@property (nonatomic, retain) FLActionButton *participateButton;

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller preset:(FLPreset *)preset actionParticipate:(SEL)actionParticipate;
- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller preset:(FLPreset *)preset actionSend:(SEL)actionSend actionCharge:(SEL)actionCharge;
- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller preset:(FLPreset *)preset actionCollect:(SEL)actionCollect;
- (void)reloadData;
- (void)enablePaymentButtons:(BOOL)enable;
- (void)hideChargeButton:(BOOL)hidden;
- (void)hidePayButton:(BOOL)hidden;
- (void)hideButtonSeparator:(BOOL)hidden;

@end
