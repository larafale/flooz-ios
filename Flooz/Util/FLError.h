//
//  FLError.h
//  Flooz
//
//  Created by jonathan on 2/3/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#define DISPLAY_ERROR(error) [appDelegate displayError:[NSError errorWithDomain:@"com.flooz.Flooz" code:error userInfo:nil]];
#define ERROR_LOCALIZED_DESCRIPTION(code) NSLocalizedStringFromTable(([NSString stringWithFormat:@"%ld", code]), @"Error", nil)

enum {
    FLNetworkError = 1000,
    
    FLBadLoginError,

    FLAlbumsAccessDenyError,
    FLCameraAccessDenyError,
    FLGPSAccessDenyError,
    FLContactAccessDenyError,
};