//
//  FLCopyLinkActivity.m
//  Flooz
//
//  Created by Olive on 12/23/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "FLCopyLinkActivity.h"

@implementation FLCopyLinkActivity {
    NSURL *_activityURL;
}

@synthesize activityTitle = _activityTitle;

- (void)commonInit {
    _activityTitle = NSLocalizedString(@"COPY_LINK", nil);
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"copy-link"];
}

- (NSString *)activityType {
    return NSStringFromClass([self class]);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems){
        if ([item isKindOfClass:NSURL.class]){
            NSURL *url = (NSURL *)item;
            if (![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"]) {
                return NO;
            }
        } else
            return NO;
    }
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:NSURL.class]) {
            NSURL *url = (NSURL *)item;
            if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
                _activityURL = (NSURL *)item;
                return;
            }
            
        }
    }
}

- (void)performActivity {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    [pasteboard setURL:_activityURL];
    
    [self activityDidFinish:YES];
}

@end
