//
//  FLNewTransactionBar.h
//  Flooz
//
//  Created by olivier on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import "FLTransaction.h"
#import "WYPopoverController.h"
#import "FLPrivacySelectorViewController.h"
#import "FLPreset.h"

@protocol FLNewTransactionBarDelegate <NSObject>

- (void) scopePopoverWillAppear;
- (void) scopePopoverDidDisappear;

@end

@interface FLNewTransactionBar : UIView <CLLocationManagerDelegate, WYPopoverControllerDelegate, FLPrivacySelectorDelegate> {
	SEL actionValidSend;
	SEL actionValidCollect;
    SEL actionValidCharge;
    SEL actionValidParticipation;

	__weak NSMutableDictionary *_dictionary;
	CLLocationManager *locationManager;

	__weak UIViewController *currentController;
}

@property (weak) id <FLNewTransactionBarDelegate> delegate;
@property (nonatomic, retain) UIButton *imageButton;;
@property (nonatomic, retain) UIButton *facebookButton;;
@property (nonatomic, retain) UIButton *privacyButton;;
@property (nonatomic, retain) UIButton *locationButton;;
@property (nonatomic, retain) FLActionButton *askButton;;
@property (nonatomic, retain) FLActionButton *sendButton;;
@property (nonatomic, retain) FLActionButton *collectButton;
@property (nonatomic, retain) FLActionButton *participateButton;

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller preset:(FLPreset *)preset actionParticipate:(SEL)actionParticipate;
- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller preset:(FLPreset *)preset actionSend:(SEL)actionSend actionCharge:(SEL)actionCharge;
- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller preset:(FLPreset *)preset actionCollect:(SEL)actionCollect;
- (void)reloadData;
- (void)enablePaymentButtons:(BOOL)enable;
- (void)hideChargeButton:(BOOL)hidden;
- (void)hidePayButton:(BOOL)hidden;

@end
