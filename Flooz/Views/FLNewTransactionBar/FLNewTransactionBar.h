//
//  FLNewTransactionBar.h
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@interface FLNewTransactionBar : UIView<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>{
    UIButton *localizeButton;
    UIButton *imageButton;
    UIButton *facebookButton;
    UIButton *privacyButton;
    UILabel *circle;
    
    UIButton *askButton;
    UIButton *sendButton;
    
    SEL actionValidSend;
    SEL actionValidCollect;
    
    __weak NSMutableDictionary *_dictionary;
    CLLocationManager *locationManager;
    
    BOOL isEvent;
    
    __weak UIViewController* currentController;
}

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller actionSend:(SEL)actionSend actionCollect:(SEL)actionCollect;
- (void)reloadData;

@end
