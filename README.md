<p align="center" >
  <img src="https://www.flooz.me/img/logo/flooz.png" alt="Flooz" title="Flooz" width="300px">
</p>

![build passing](http://b.repl.ca/v1/build-passing-brightgreen.png)
![version 3.2.0](http://b.repl.ca/v1/version-3.2.0-lightgrey.png)
![platform ios](http://b.repl.ca/v1/platform-ios-lightgrey.png)
![dependencies up to date](http://b.repl.ca/v1/dependencies-up_to%20date-brightgreen.png)
[![twitter @floozme](http://b.repl.ca/v1/twitter-@floozme-blue.png)](http://twitter.com/floozme)

## Installation

Flooz uses [CocoaPods](http://cocoapods.org) as dependency manager, which automates and simplifies the process of using 3rd-party libraries.

####Installation process

```bash
$ git clone https://github.com/larafale/flooz-ios.git
$ cd flooz-ios
$ pod install
$ open Flooz.xcworkspace
```
> CocoaPods 1.+ and Xcode 8 are required to build Flooz.

## Architecture

### Libraries

| Name | Version  | Notes |
|:-------------------------------:|:--------------------:|:------------------------------------------------------------------:|
| [ActionSheetPicker-3.0](https://github.com/skywinder/ActionSheetPicker-3.0) | 2.2.0 | Quickly reproduce the dropdown UIPickerView / ActionSheet functionality on iOS |
| [AFNetworking](https://github.com/AFNetworking/AFNetworking) | 3.1.0 | A delightful networking framework for iOS, OS X, watchOS, and tvOS |
| [Branch](https://github.com/BranchMetrics/ios-branch-deep-linking) | 0.12.3 | Branch helps mobile apps grow with deep links / deeplinks that power referral systems, sharing links and invites with full attribution and analytics |
| [CardIO](https://github.com/card-io/card.io-iOS-SDK) | 5.3.2 | Card.io provides fast, easy credit card scanning in mobile apps |
| [Crashlytics](https://cocoapods.org/pods/Crashlytics) | 3.7.2 | Part of Twitter Fabric, Crashlytics offers the most powerful, yet lightest weight crash reporting solution for iOS |
| [EAIntroView](https://github.com/ealeksandrov/EAIntroView) | 2.9.0 | Highly customizable drop-in solution for introduction views |
| [Fabric](http://fabric.io) | 1.6.7 | With Fabric, you’ll have instant access to the same features you love within Crashlytics and more. Get a snapshot of your app’s health in real-time, understand what’s truly important and fix the most prevalent crashes |
| [FBSDKCoreKit](https://developers.facebook.com/docs/ios/) | 4.13.1 | Used to integrate iOS apps with Facebook Platform |
| [FBSDKLoginKit](https://developers.facebook.com/docs/ios/) | 4.13.1 | Used to integrate iOS apps with Facebook Platform |
| [FBSDKMessengerShareKit](https://developers.facebook.com/docs/ios/) | 1.3.2 | Used to integrate iOS apps with Facebook Messenger Platform |
| [FBSDKShareKit](https://developers.facebook.com/docs/ios/) | 4.13.1 | Used to integrate iOS apps with Facebook Platform |
| [FXBlurView](https://github.com/nicklockwood/FXBlurView) | 1.6.4 | UIView subclass that replicates the iOS 7 realtime background blur effect, but works on iOS 5 and above |
| [GBDeviceInfo](https://github.com/lmirosevic/GBDeviceInfo) | 4.1.0 | Detects the hardware, software and display of the current iOS or Mac OS X device at runtime |
| [HHRouter](https://github.com/Huohua/HHRouter) | 0.1.9 | URL Router for iOS. Clean, Fast & Flexible. Inspired by ABRouter & Routable iOS |
| [HMSegmentedControl](https://github.com/HeshamMegid/HMSegmentedControl) | 1.5.2 | A drop-in replacement for UISegmentedControl mimicking the style of the segmented control used in Google Currents and various other Google products |
| [iCarousel](https://github.com/nicklockwood/iCarousel) | 1.8.2 | A simple, highly customisable, data-driven 3D carousel for iOS and Mac OS |
| [IDMPhotoBrowser](https://github.com/ideaismobile/IDMPhotoBrowser) | 1.8.4 | Photo Browser / Viewer inspired by Facebook's and Tweetbot's with ARC support, swipe-to-dismiss, image progress and more |
| [JPSVolumeButtonHandler](https://github.com/jpsim/JPSVolumeButtonHandler) | 1.0.1 | JPSVolumeButtonHandler provides an easy block interface to hardware volume buttons on iOS devices |
| [JTHelper](https://github.com/jonathantribouharet/JTHelper) | 0.3.0 | List of common helpers for iOS projects |
| [JTSImageViewController](https://github.com/jaredsinclair/JTSImageViewController) | 1.5.1 | An interactive iOS image viewer that does it all: double tap to zoom, flick to dismiss, et cetera |
| [libPhoneNumber-iOS](https://github.com/iziz/libPhoneNumber-iOS) | 0.8.14 | iOS port from libphonenumber (Google's phone number handling library) |
| [MGSwipeTableCell](https://github.com/MortimerGoro/MGSwipeTableCell) | 1.5.5 | An easy to use UITableViewCell subclass that allows to display swippable buttons with a variety of transitions |
| [Mixpanel](https://mixpanel.com/help/reference/ios) | 3.0.0 | iPhone tracking library for Mixpanel Analytics |
| [MZFormSheetController](https://github.com/m1entus/MZFormSheetController) | 3.1.3 | MZFormSheetController provides an alternative to the native iOS UIModalPresentationFormSheet, adding support for iPhone and additional opportunities to setup controller size and feel form sheet |
| [NSDate+Calendar](https://github.com/belkevich/nsdate-calendar) | 0.0.9 | NSDate categories to access date components and many more |
| [OneSignal](https://github.com/OneSignal/OneSignal-iOS-SDK) | 1.13.3 | OneSignal is a free push notification service for mobile apps. This plugin makes it easy to integrate your native iOS app with OneSignal |
| [PonyDebugger](https://github.com/square/PonyDebugger) | 0.4.5 | Remote network and data debugging for your native iOS app using Chrome Developer Tools |
| [PPHelpMe](https://github.com/ipodishima/PPHelpMe) | 1.0.2 | List of common helpers for iOS projects |
| [RDVTabBarController](https://github.com/robbdimitrov/RDVTabBarController) | 1.1.9 | Highly customizable tabBar and tabBarController for iOS |
| [SDWebImage](https://github.com/rs/SDWebImage) | 3.8.1 | Asynchronous image downloader with cache support as a UIImageView category |
| [SMPageControl](https://github.com/Spaceman-Labs/SMPageControl) | 1.2 | A drop in replacement for UIPageControl with a slew of additional customization options |
| [Stripe](https://github.com/stripe/stripe-ios) | 8.0.0 | Stripe bindings for iOS and OS X |
| [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) | 2.0.0 | A drop-in replacement for UILabel that supports attributes, data detectors, links, and more |
| [TUSafariActivity](https://github.com/davbeck/TUSafariActivity) | 1.0.4 | A UIActivity subclass that opens URLs in Safari |
| [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore) | 2.1.0 | UICKeyChainStore is a simple wrapper for Keychain on iOS. Makes using Keychain APIs as easy as NSUserDefaults |
| [UIFloatLabelTextField](https://github.com/ArtSabintsev/UIFloatLabelTextField) | 1.2.5 | A subclassed UITextField that follows the Float Label UI design pattern |
| [VCTransitionsLibrary](https://github.com/ColinEberhardt/VCTransitionsLibrary) | 1.5.0 | A collection of iOS7 animation controllers and interaction controllers, providing flip, fold and all kinds of other transitions |
| [VENCalculatorInputView](https://github.com/venmo/VENCalculatorInputView) | 1.5.4 | Calculator keyboard used in the Venmo iOS app |

### Model

* `<AFURLRequestSerialization>`
  - `AFHTTPRequestSerializer`
  - `AFJSONRequestSerializer`
  - `AFPropertyListRequestSerializer`
* `<AFURLResponseSerialization>`
  - `AFHTTPResponseSerializer`
  - `AFJSONResponseSerializer`
  - `AFXMLParserResponseSerializer`
  - `AFXMLDocumentResponseSerializer` _(Mac OS X)_
  - `AFPropertyListResponseSerializer`
  - `AFImageResponseSerializer`
  - `AFCompoundResponseSerializer`

### UI

- `AFSecurityPolicy`
- `AFNetworkReachabilityManager`
