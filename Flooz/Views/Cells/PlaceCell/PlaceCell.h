//
//  PlaceCell.h
//  Flooz
//
//  Created by Epitech on 11/2/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaceCelldelegate <NSObject>

- (void)removeButtonClicked;

@end

@interface PlaceCell : UITableViewCell

@property (nonatomic, retain) NSDictionary *place;

@property (nonatomic) id<PlaceCelldelegate> delegate;

+ (CGFloat)getHeight;

- (void)showRemoveButton;
- (void)hideRemoveButton;

@end
