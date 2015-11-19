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
    UISearchBar *_searchBar;
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet id <LocationSearchBarDelegate> delegate;

- (id)initWithStartX:(CGFloat)xStart;
- (id)initWithFrame:(CGRect)frame;
- (void)close;

@end