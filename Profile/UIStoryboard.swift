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

  class func homeViewController() -> HomeViewController {
    return mainStoryboard().instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
  }

  class func teamItemViewController() -> TeamItemViewController {
    return mainStoryboard().instantiateViewControllerWithIdentifier("TeamItemViewController") as! TeamItemViewController
  }

  class func workItemViewController() -> WorkItemViewController {
    return mainStoryboard().instantiateViewControllerWithIdentifier("WorkItemViewController") as! WorkItemViewController
  }

}
