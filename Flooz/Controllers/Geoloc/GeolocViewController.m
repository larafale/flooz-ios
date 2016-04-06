//
//  GeolocViewController.m
//  Flooz
//
//  Created by Epitech on 11/2/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "PlaceCell.h"
#import "LoadingCell.h"
#import "GeolocViewController.h"


@interface GeolocViewController () {
    LocationSearchBar *_searchBar;
    FLTableView *_tableView;
    
    BOOL isSearching;
    
    BOOL suggestsLoaded;
    BOOL searchLoaded;
    
    CLLocationManager *locationManager;
    
    CLLocation *currentLocation;
    
    NSString *currentSearch;
    
    NSArray *placesSearch;
    NSArray *placesSuggest;
    CGFloat emptyCellHeight;
    
}

@end

@implementation GeolocViewController

@synthesize delegate;
@synthesize selectedPlace;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSearching = NO;
    searchLoaded = NO;
    suggestsLoaded = NO;
    currentLocation = nil;
    currentSearch = @"";
    placesSuggest = @[];
    placesSearch = @[];
    
    CGFloat searchMargin = 120;
    
    _searchBar = [[LocationSearchBar alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth() - searchMargin, 40)];
    [_searchBar setDelegate:self];
    
    _tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame)) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView setSeparatorColor:[UIColor customBackground]];
    
    [_mainBody addSubview:_tableView];
    
    _tableView.backgroundColor = [UIColor customBackgroundHeader];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse ) {
        [locationManager requestWhenInUseAuthorization];
    } else {
        [locationManager startUpdatingLocation];
    }
    
    emptyCellHeight = 35;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView = _searchBar;
    
    [self registerForKeyboardNotifications];
    [self registerNotification:@selector(scrollViewDidScroll:) name:kNotificationCloseKeyboard object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return NSLocalizedString(@"SELECTED_LOCATION", nil);
    
    if (isSearching)
        return NSLocalizedString(@"LOCATION_RESULTS", nil);
    
    return NSLocalizedString(@"AROUND_YOU", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (selectedPlace)
            return 1;
        else
            return 0;
    }
    if (isSearching) {
        if (placesSearch.count)
            return placesSearch.count;
        return 1;
    }
    
    if (placesSuggest.count)
        return placesSuggest.count;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (selectedPlace)
            return 25;
        return CGFLOAT_MIN;
    }
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return [PlaceCell getHeight];
    else {
        if (isSearching) {
            if (placesSearch.count)
                return [PlaceCell getHeight];
            else if (searchLoaded)
                return emptyCellHeight;
            return [LoadingCell getHeight];
        }
        
        if (placesSuggest.count)
            return [PlaceCell getHeight];
        else if (suggestsLoaded)
            return emptyCellHeight;
        
        return [LoadingCell getHeight];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 && !selectedPlace)
        return [UIView new];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), [self tableView:tableView heightForHeaderInSection:section])];
    headerView.backgroundColor = [UIColor customBackground];
    
    UILabel *headerTitle = [[UILabel alloc] initWithText:[self tableView:tableView titleForHeaderInSection:section] textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
    
    [headerView addSubview:headerTitle];
    
    CGRectSetX(headerTitle.frame, 14);
    CGRectSetY(headerTitle.frame, CGRectGetHeight(headerView.frame) / 2 - CGRectGetHeight(headerTitle.frame) / 2 + 1);
    
    return headerView;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView placeCellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString *cellIdentifier = @"PlacesCell";
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *place;
    
    if (indexPath.section == 0)
        place = selectedPlace;
    else {
        if (isSearching)
            place = [placesSearch objectAtIndex:indexPath.row];
        else
            place = [placesSuggest objectAtIndex:indexPath.row];
    }
    
    [cell setPlace:place];
    [cell setDelegate:self];
    
    if (indexPath.section == 0)
        [cell showRemoveButton];
    
    return cell;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isSearching) {
        if (placesSearch.count)
            return [self tableView:tableView placeCellForRowAtIndexPath:indexPath];
        else if (searchLoaded)
            return [self generateEmptyplaceCell];
        return [LoadingCell new];
    }
    
    if (placesSuggest.count)
        return [self tableView:tableView placeCellForRowAtIndexPath:indexPath];
    else if (suggestsLoaded)
        return [self generateEmptyplaceCell];
    
    return [LoadingCell new];
}

- (UITableViewCell *) generateEmptyplaceCell {
    static UITableViewCell *emptyCell;
    
    if (!emptyCell) {
        emptyCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), emptyCellHeight)];
        [emptyCell setBackgroundColor:[UIColor clearColor]];
        [emptyCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UILabel *text = [[UILabel alloc] initWithText:NSLocalizedString(@"EMPTY_LOCATION", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:17] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        
        [text setWidthToFit];
        
        CGRectSetY(text.frame, emptyCellHeight / 2 - CGRectGetHeight(text.frame) / 2);
        CGRectSetX(text.frame, PPScreenWidth() / 2 - CGRectGetWidth(text.frame) / 2);
        
        [emptyCell addSubview:text];
    }
    
    return emptyCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *place;
    
    if (indexPath.section) {
        if (isSearching) {
            if (placesSearch.count)
                place = [placesSearch objectAtIndex:indexPath.row];
            else if (searchLoaded)
                return;
        } else {
            if (placesSuggest.count)
                place = [placesSuggest objectAtIndex:indexPath.row];
            else if (suggestsLoaded)
                return;
        }
    }
    
    if (place) {
        if (delegate)
            [delegate locationPlaceSelected:place];
        
        [self dismissViewController];
    }
}

- (void)didFilterChange:(NSString *)text {
    currentSearch = text;
    if (currentLocation) {
        if (text.length < 3) {
            isSearching = NO;
            
            if (placesSuggest.count) {
                [_tableView reloadData];
            } else {
                [[Flooz sharedInstance] placesFrom:[NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude] success:^(id result) {
                    suggestsLoaded = YES;
                    placesSuggest = result;
                    [_tableView reloadData];
                } failure:^(NSError *error) {
                    [_tableView reloadData];
                }];
            }
            return;
        }
        
        isSearching = YES;
        searchLoaded = NO;
        
        placesSearch = @[];
        [_tableView reloadData];
        
        [[Flooz sharedInstance] placesSearch:currentSearch from:[NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude] success:^(id result) {
            searchLoaded = YES;
            placesSearch = result;
            [_tableView reloadData];
        } failure:^(NSError *error) {
            [_tableView reloadData];
        }];
    }
}

- (void)removeButtonClicked {
    if (delegate)
        [delegate removeLocation];
    
    selectedPlace = nil;
    [_tableView reloadData];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
    
    [self didFilterChange:currentSearch];
    
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            
        } break;
        case kCLAuthorizationStatusDenied: {
            [self dismissViewController];
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [locationManager startUpdatingLocation];
        } break;
        default:
            break;
    }
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear {
    _tableView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidScroll:(id)scrollView {
    [_searchBar close];
}

@end
