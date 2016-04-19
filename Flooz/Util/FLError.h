//
//  FLError.h
//  Flooz
//
//  Created by Olivier on 2/3/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#define DISPLAY_ERROR(error) [appDelegate displayError :[NSError errorWithDomain:@"com.flooz.Flooz" code:error userInfo:nil]];
#define ERROR_LOCALIZED_DESCRIPTION(code) (NSLocalizedStringFromTable(([NSString stringWithFormat:@"%d", code]), @"Error", nil))

enum {
	FLNetworkError = 1000,

	FLBadLoginError,

	FLAlbumsAccessDenyError,
	FLCameraAccessDenyError,
	FLGPSAccessDenyError,
	FLContactAccessDenyError,
	FLNeedUpdateError,
};
