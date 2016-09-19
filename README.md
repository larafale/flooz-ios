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

### Installation process

```bash
$ git clone https://github.com/larafale/flooz-ios.git
$ cd flooz-ios
$ pod install
$ open Flooz.xcworkspace
```
> CocoaPods 1.+ and Xcode 8 are required to build Flooz.

## Architecture

### [Libraries](https://github.com/larafale/flooz-ios/blob/master/Podfile)

| Name | Version  | Notes |
|:-------------------------------:|:--------------------:|:------------------------------------------------------------------:|
| [ActionSheetPicker-3.0](https://github.com/skywinder/ActionSheetPicker-3.0) | _2.2.0_ | Quickly reproduce the dropdown UIPickerView / ActionSheet functionality on iOS |
| [AFNetworking](https://github.com/AFNetworking/AFNetworking) | _3.1.0_ | A delightful networking framework for iOS, OS X, watchOS, and tvOS |
| [Branch](https://github.com/BranchMetrics/ios-branch-deep-linking) | _0.12.3_ | Branch helps mobile apps grow with deep links / deeplinks that power referral systems, sharing links and invites with full attribution and analytics |
| [CardIO](https://github.com/card-io/card.io-iOS-SDK) | _5.3.2_ | Card.io provides fast, easy credit card scanning in mobile apps |
| [Crashlytics](https://cocoapods.org/pods/Crashlytics) | _3.7.2_ | Part of Twitter Fabric, Crashlytics offers the most powerful, yet lightest weight crash reporting solution for iOS |
| [EAIntroView](https://github.com/ealeksandrov/EAIntroView) | _2.9.0_ | Highly customizable drop-in solution for introduction views |
| [Fabric](http://fabric.io) | _1.6.7_ | With Fabric, you’ll have instant access to the same features you love within Crashlytics and more. Get a snapshot of your app’s health in real-time, understand what’s truly important and fix the most prevalent crashes |
| [FBSDKCoreKit](https://developers.facebook.com/docs/ios/) | _4.13.1_ | Used to integrate iOS apps with Facebook Platform |
| [FBSDKLoginKit](https://developers.facebook.com/docs/ios/) | _4.13.1_ | Used to integrate iOS apps with Facebook Platform |
| [FBSDKMessengerShareKit](https://developers.facebook.com/docs/ios/) | 1.3.2 | Used to integrate iOS apps with Facebook Messenger Platform |
| [FBSDKShareKit](https://developers.facebook.com/docs/ios/) | _4.13.1_ | Used to integrate iOS apps with Facebook Platform |
| [FXBlurView](https://github.com/nicklockwood/FXBlurView) | _1.6.4_ | UIView subclass that replicates the iOS 7 realtime background blur effect, but works on iOS 5 and above |
| [GBDeviceInfo](https://github.com/lmirosevic/GBDeviceInfo) | _4.1.0_ | Detects the hardware, software and display of the current iOS or Mac OS X device at runtime |
| [HHRouter](https://github.com/Huohua/HHRouter) | _0.1.9_ | URL Router for iOS. Clean, Fast & Flexible. Inspired by ABRouter & Routable iOS |
| [HMSegmentedControl](https://github.com/HeshamMegid/HMSegmentedControl) | _1.5.2_ | A drop-in replacement for UISegmentedControl mimicking the style of the segmented control used in Google Currents and various other Google products |
| [iCarousel](https://github.com/nicklockwood/iCarousel) | _1.8.2_ | A simple, highly customisable, data-driven 3D carousel for iOS and Mac OS |
| [IDMPhotoBrowser](https://github.com/ideaismobile/IDMPhotoBrowser) | _1.8.4_ | Photo Browser / Viewer inspired by Facebook's and Tweetbot's with ARC support, swipe-to-dismiss, image progress and more |
| [JPSVolumeButtonHandler](https://github.com/jpsim/JPSVolumeButtonHandler) | _1.0.1_ | JPSVolumeButtonHandler provides an easy block interface to hardware volume buttons on iOS devices |
| [JTHelper](https://github.com/jonathantribouharet/JTHelper) | _0.3.0_ | List of common helpers for iOS projects |
| [JTSImageViewController](https://github.com/jaredsinclair/JTSImageViewController) | _1.5.1_ | An interactive iOS image viewer that does it all: double tap to zoom, flick to dismiss, et cetera |
| [libPhoneNumber-iOS](https://github.com/iziz/libPhoneNumber-iOS) | _0.8.14_ | iOS port from libphonenumber (Google's phone number handling library) |
| [MGSwipeTableCell](https://github.com/MortimerGoro/MGSwipeTableCell) | _1.5.5_ | An easy to use UITableViewCell subclass that allows to display swippable buttons with a variety of transitions |
| [Mixpanel](https://mixpanel.com/help/reference/ios) | _3.0.0_ | iPhone tracking library for Mixpanel Analytics |
| [MZFormSheetController](https://github.com/m1entus/MZFormSheetController) | _3.1.3_ | MZFormSheetController provides an alternative to the native iOS UIModalPresentationFormSheet, adding support for iPhone and additional opportunities to setup controller size and feel form sheet |
| [NSDate+Calendar](https://github.com/belkevich/nsdate-calendar) | _0.0.9_ | NSDate categories to access date components and many more |
| [OneSignal](https://github.com/OneSignal/OneSignal-iOS-SDK) | _1.13.3_ | OneSignal is a free push notification service for mobile apps. This plugin makes it easy to integrate your native iOS app with OneSignal |
| [PonyDebugger](https://github.com/square/PonyDebugger) | _0.4.5_ | Remote network and data debugging for your native iOS app using Chrome Developer Tools |
| [PPHelpMe](https://github.com/ipodishima/PPHelpMe) | _1.0.2_ | List of common helpers for iOS projects |
| [RDVTabBarController](https://github.com/robbdimitrov/RDVTabBarController) | _1.1.9_ | Highly customizable tabBar and tabBarController for iOS |
| [SDWebImage](https://github.com/rs/SDWebImage) | _3.8.1_ | Asynchronous image downloader with cache support as a UIImageView category |
| [SMPageControl](https://github.com/Spaceman-Labs/SMPageControl) | _1.2_ | A drop in replacement for UIPageControl with a slew of additional customization options |
| [Stripe](https://github.com/stripe/stripe-ios) | _8.0.0_ | Stripe bindings for iOS and OS X |
| [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) | _2.0.0_ | A drop-in replacement for UILabel that supports attributes, data detectors, links, and more |
| [TUSafariActivity](https://github.com/davbeck/TUSafariActivity) | _1.0.4_ | A UIActivity subclass that opens URLs in Safari |
| [UICKeyChainStore](https://github.com/kishikawakatsumi/UICKeyChainStore) | _2.1.0_ | UICKeyChainStore is a simple wrapper for Keychain on iOS. Makes using Keychain APIs as easy as NSUserDefaults |
| [UIFloatLabelTextField](https://github.com/ArtSabintsev/UIFloatLabelTextField) | _1.2.5_ | A subclassed UITextField that follows the Float Label UI design pattern |
| [VCTransitionsLibrary](https://github.com/ColinEberhardt/VCTransitionsLibrary) | _1.5.0_ | A collection of iOS7 animation controllers and interaction controllers, providing flip, fold and all kinds of other transitions |
| [VENCalculatorInputView](https://github.com/venmo/VENCalculatorInputView) | _1.5.4_ | Calculator keyboard used in the Venmo iOS app |

### [Models](https://github.com/larafale/flooz-ios/tree/master/Flooz/Models)

######The models are initialized from API calls, several kinds of models are available:

- `FLAlert` _In-App alert object (appear from top)_
- `FLComment` _Transaction and pot comment object_
- `FLCountry` _Country object with flag, phone prefix..._
- `FLCreditCard` _Credit card object with holder, card number, expires..._
- `FLFriendRequest` _Pending friend request object_
- `FLInvitationTexts` _Invitations texts used for app sharing (Fb, twitter, mail, sms)_
- `FLNotification` _Notification object (text, cAt)_
- `FLPreset` _Preset object used for initalizing new collect or new flooz view from Triggers_
- `FLReport` _Report object used when sending user or transaction report to the API_
- `FLShopItem` _Shop item can be a product or category_
- `FLSocial` _Social data from collect and transactions (nbLikes, nbComments, ...)_
- `FLTexts` _Texts sended from API, used to manage all kinds of content whitin the app_
- `FLTransaction` _Transaction object (can be a pot)_
- `FLTrigger` _Trigger object with next triggers, data and kind_
- `FLUser` _User object with all visible informations_

### UI


### Networking

##### JSON REST


##### SocketIO


### Triggers

