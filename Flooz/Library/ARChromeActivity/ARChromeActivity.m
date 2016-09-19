/*
  ARChromeActivity.m

  Copyright (c) 2012 Alex Robinson
 
  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "ARChromeActivity.h"
#import "OpenInChromeController.h"

@implementation ARChromeActivity {
    NSURL *_activityURL;
    OpenInChromeController *chromeController;
}

@synthesize callbackURL = _callbackURL;
@synthesize activityTitle = _activityTitle;

- (void)commonInit {
    _activityTitle = NSLocalizedString(@"OPEN_CHROME", nil);
    chromeController = [OpenInChromeController new];
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCallbackURL:(NSURL *)callbackURL {
    self = [super init];
    if (self) {
        [self commonInit];
        _callbackURL = callbackURL;
    }
    return self;
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"chrome"];
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
    return [chromeController isChromeInstalled];
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
    [chromeController openInChrome:_activityURL withCallbackURL:self.callbackURL createNewTab:YES];
    [self activityDidFinish:YES];
}

@end
