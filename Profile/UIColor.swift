//
//  UIColor.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

extension UIColor {

  class func profilePrimaryBlackColor() -> UIColor {
    return UIColor.blackColor()
  }

  class func profileSecondaryBlackColor() -> UIColor {
    return UIColor(red: 69.0/255.0, green: 69.0/255.0, blue: 69.0/255.0, alpha: 1.0) // #454545
  }

  class func profilePrimaryWhiteColor() -> UIColor {
    return UIColor.whiteColor()
  }

  class func profileSecondaryWhiteColor() -> UIColor {
    return UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0) // #d3d3d3
  }

}
