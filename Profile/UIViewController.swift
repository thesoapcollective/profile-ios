//
//  UIViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 2/11/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit

extension UIViewController {

  func tryToEmail(email: String, subject: String?) {
    var urlString = "mailto:\(email)"
    if subject != nil {
      urlString += "?subject=\(subject!.stringByReplacingOccurrencesOfString(" ", withString: "%20"))"
    }
    guard let url = NSURL(string: urlString) else { return }
    if UIApplication.sharedApplication().canOpenURL(url) {
      UIApplication.sharedApplication().openURL(url)
    } else {
      let alertViewController = UIAlertController(title: "Cannot send email!", message: "Configure at least one email account in the Mail app and try again.", preferredStyle: .Alert)
      alertViewController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
      presentViewController(alertViewController, animated: true, completion: nil)
    }
  }

  func askToCall(phoneNumber: String, name: String) {
    guard let url = NSURL(string: "tel:\(phoneNumber)") else { return }
    if UIApplication.sharedApplication().canOpenURL(url) {
      let alertViewController = UIAlertController(title: "Want to give \(name) a call?", message: nil, preferredStyle: .Alert)
      alertViewController.addAction(UIAlertAction(title: "No thanks.", style: .Cancel, handler: nil))
      alertViewController.addAction(UIAlertAction(title: "Yes!", style: .Default, handler: { (alertAction) -> Void in
        UIApplication.sharedApplication().openURL(url)
      }))
      presentViewController(alertViewController, animated: true, completion: nil)
    }
  }

}
