//
//  GeolocViewController.h
//  Flooz
//
//  Created by Epitech on 11/2/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import <MapKit/MapKit.h>

#import "PlaceCell.h"
#import "LocationSearchBar.h"

@protocol GeolocDelegate <NSObject>

- (void) locationPlaceSelected:(NSDictionary *)place;
- (void) removeLocation;

@end

@interface GeolocViewController : BaseViewController<CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, LocationSearchBarDelegate, PlaceCelldelegate>

@property (nonatomic) id<GeolocDelegate> delegate;
@property (nonatomic, retain) NSDictionary *selectedPlace;


@end
