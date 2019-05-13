# CallKit Extension for iOS

Apple's CallKit framework for iOS is often used to create integrated VoIP apps for the iPhone..
CallKit also lets you add numbers to the phone block list and Caller ID lists.  This is the capability we explore in this tutorial.

In this tutorial you will create:

* An iOS app that you can use to add names and numbers to a caller ID list and add numbers to a block list.
* A CallKit extension that provides these lists to the iOS phone app.

The full tutorials can be found at:

* [CallKit extension for iOS - Part 1](https://pusher.com/tutorials/callkit-ios-part-1)
* [CallKit extension for iOS - Part 2](https://pusher.com/tutorials/callkit-ios-part-2)

## Getting Started

Full instructions on how

If you clone this repository, you will need to make some changes in Xcode to get it running on your phone:

* Change the app bundle to make it unique (Use your own domain name).
* Change the application group to make it unique (Use `group.your.domain.name`).
* Change the signing team to your development team.

### Prerequisites

* A Mac with Xcode 10
* An iPhone (You cannot use the simulator to test CallKit extensions)
* Familiarity with XCode and storyboards
* Familiarity with general UIKit programming

## Built With

* [Swift](https://swift.org)
* [Xcode](https://developer.apple.com)
