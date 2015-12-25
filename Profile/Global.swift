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

  static let ProfileModeChangedNotification = "ProfileModeChangedNotification"

  static var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

  static var mode: ProfileMode = .Light {
    didSet {
      NSNotificationCenter.defaultCenter().postNotificationName(ProfileModeChangedNotification, object: nil)
    }
  }

}
