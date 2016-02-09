//
//  Global.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

enum ProfileMode {
  case Light
  case Dark
}

struct Global {

  static let AppBootedNotification = "AppBootedNotification"
  static let ArrowTopTappedNotification = "ArrowTopTappedNotification"
  static let ArrowBottomTappedNotification = "ArrowBottomTappedNotification"
  static let CloseContactNotification = "CloseContactNotification"
  static let CloseIndexNotification = "CloseIndexNotification"
  static let ContactPanningNotification = "ContactPanningNotification"
  static let ContactStateChanged = "ContactStatedChanged"
  static let DataLoaded = "DataLoaded"
  static let IndexPanningNotification = "IndexPanningNotification"
  static let IndexStateChanged = "IndexStateChanged"
  static let OpenContactNotification = "OpenContactNotification"
  static let OpenIndexNotification = "OpenIndexNotification"
  static let ProfileModeChangedNotification = "ProfileModeChangedNotification"
  static let ScrollChangedNotification = "ScrollChangedNotification"
  static let ScrollEndedNotification = "ScrollEndedNotification"

  static let TeamArrowOffset: CGFloat = 30
  static let WorkArrowOffset: CGFloat = 25

  static let ParallaxOffset3: CGFloat = 50
  static let ParallaxOffset2: CGFloat = 40
  static let ParallaxOffset1: CGFloat = -30

  static let SwipeThreshold: CGFloat = 30

  static var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
  static var isAppBooted = false

  static var mode: ProfileMode = .Light {
    didSet {
      NSNotificationCenter.defaultCenter().postNotificationName(ProfileModeChangedNotification, object: nil)
    }
  }

  static var isContactOpen = false {
    didSet {
      if isContactOpen != oldValue {
        NSNotificationCenter.defaultCenter().postNotificationName(ContactStateChanged, object: nil)
      }
    }
  }

  static var isIndexOpen = false {
    didSet {
      if isIndexOpen != oldValue {
        NSNotificationCenter.defaultCenter().postNotificationName(IndexStateChanged, object: nil)
      }
    }
  }

}
