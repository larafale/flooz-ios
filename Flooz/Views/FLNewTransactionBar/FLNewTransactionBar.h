//
//  FLNewTransactionBar.h
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import "FLTransaction.h"

@interface FLNewTransactionBar : UIView <CLLocationManagerDelegate> {
	UIButton *localizeButton;
	UIButton *imageButton;
	UIButton *facebookButton;
	UIButton *privacyButton;
	UILabel *circle;

	FLActionButton *askButton;
	FLActionButton *sendButton;

	SEL actionValidSend;
	SEL actionValidCollect;

	__weak NSMutableDictionary *_dictionary;
	CLLocationManager *locationManager;

	__weak UIViewController *currentController;
}

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller actionSend:(SEL)actionSend actionCollect:(SEL)actionCollect;
- (void)reloadData;

@end
