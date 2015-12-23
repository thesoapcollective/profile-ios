//
//  UIStoryboard.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

extension UIStoryboard {

  class func mainStoryboard() -> UIStoryboard {
    return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
  }

  class func homeViewController() -> UIViewController {
    return mainStoryboard().instantiateViewControllerWithIdentifier("HomeViewController")
  }

  class func itemViewController() -> ItemViewController {
    return mainStoryboard().instantiateViewControllerWithIdentifier("ItemViewController") as! ItemViewController
  }

}
