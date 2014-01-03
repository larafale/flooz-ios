//
//  Flooz.h
//  Flooz
//
//  Created by jonathan on 12/30/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Flooz : NSObject

+ (id)connectWithLogin:(NSString*)login password:(NSString*) password;
+ (id)connectFacebook;

@end
