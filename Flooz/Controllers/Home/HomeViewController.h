//
//  HomeViewController.h
//  Flooz
//
//  Created by Olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "iCarousel.h"

@interface HomeViewController : GlobalViewController <iCarouselDataSource, iCarouselDelegate, TTTAttributedLabelDelegate> {
}

- (void)setUserDataForSignup:(NSDictionary*)data;

@end
