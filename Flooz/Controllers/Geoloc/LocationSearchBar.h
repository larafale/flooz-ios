//
//  LocationSearchBar.h
//  Flooz
//
//  Created by Epitech on 11/2/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationSearchBarDelegate

- (void) didFilterChange:(NSString *)text;

@end

@interface LocationSearchBar : UIView <UISearchBarDelegate> {
    NSTimer *timer;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet id <LocationSearchBarDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)close;

@end
