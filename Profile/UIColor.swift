//
//  UIColor.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

extension UIColor {

  // Color Selectors

  class func appPrimaryBackgroundColor() -> UIColor {
    return Global.mode == .Light ? UIColor.appPrimaryWhiteColor() : UIColor.appPrimaryBlackColor()
  }

  class func appInvertedPrimaryBackgroundColor() -> UIColor {
    return Global.mode == .Light ? UIColor.appPrimaryBlackColor() : UIColor.appPrimaryWhiteColor()
  }

  class func appPrimaryTextColor() -> UIColor {
    return Global.mode == .Light ? UIColor.appPrimaryBlackColor() : UIColor.appPrimaryWhiteColor()
  }

  class func appInvertedPrimaryTextColor() -> UIColor {
    return Global.mode == .Light ? UIColor.appPrimaryWhiteColor() : UIColor.appPrimaryBlackColor()
  }

  class func appSecondaryTextColor() -> UIColor {
    return Global.mode == .Light ? UIColor.appSecondaryBlackColor() : UIColor.appSecondaryWhiteColor()
  }

  class func appInvertedSecondaryTextColor() -> UIColor {
    return Global.mode == .Light ? UIColor.appSecondaryWhiteColor() : UIColor.appSecondaryBlackColor()
  }

  // Colors

  class func appPrimaryBlackColor() -> UIColor {
    return UIColor.blackColor()
  }

  class func appSecondaryBlackColor() -> UIColor {
    return UIColor(red: 69.0/255.0, green: 69.0/255.0, blue: 69.0/255.0, alpha: 1.0) // #454545
  }

  class func appPrimaryWhiteColor() -> UIColor {
    return UIColor.whiteColor()
  }

  class func appSecondaryWhiteColor() -> UIColor {
    return UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0) // #d3d3d3
  }

}
