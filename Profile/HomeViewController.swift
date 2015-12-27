//
//  HomeViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/23/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

class HomeViewController: PROViewController {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var indexIconContainerView: UIView!
  @IBOutlet weak var indexIconImageView: UIImageView!
  @IBOutlet weak var indexIconDottedBorderImageView: DottedBorderImageView!
  @IBOutlet weak var mailIconContainerView: UIView!
  @IBOutlet weak var mailIconImageView: UIImageView!
  @IBOutlet weak var mailIconDottedBorderImageView: DottedBorderImageView!

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()

    logoImageView.image = logoImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    mailIconImageView.image = mailIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)

    setupGestures()
  }

  override func updateColors() {
    logoImageView.tintColor = UIColor.appPrimaryTextColor()
    indexIconImageView.tintColor = UIColor.appPrimaryTextColor()
    indexIconDottedBorderImageView.dotColor = UIColor.appPrimaryTextColor()
    mailIconImageView.tintColor = UIColor.appPrimaryTextColor()
    mailIconDottedBorderImageView.dotColor = UIColor.appPrimaryTextColor()
  }

  // ==================================================
  // GESTURES
  // ==================================================

  func setupGestures() {
    let contactTapGesture = UITapGestureRecognizer(target: self, action: "contactTapped:")
    mailIconContainerView.addGestureRecognizer(contactTapGesture)

    let indexTapGesture = UITapGestureRecognizer(target: self, action: "indexTapped:")
    indexIconContainerView.addGestureRecognizer(indexTapGesture)
  }

  func contactTapped(notification: NSNotification) {
    let notificationName = Global.isContactOpen ? Global.CloseContactNotification : Global.OpenContactNotification
    NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
  }

  func indexTapped(notification: NSNotification) {
    let notificationName = Global.isIndexOpen ? Global.CloseIndexNotification : Global.OpenIndexNotification
    NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
  }

  // ==================================================
  // NOTIFICATIONS
  // ==================================================

  override func setupNotifcations() {
    super.setupNotifcations()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "contactStateChanged:", name: Global.ContactStateChanged, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "indexStateChanged:", name: Global.IndexStateChanged, object: nil)
  }

  func contactStateChanged(notification: NSNotification) {
    let newImageIcon = Global.isContactOpen ? UIImage(named: "closeIcon") : UIImage(named: "mailIcon")
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.mailIconImageView.alpha = 0
    }) { (completed) -> Void in
      self.mailIconImageView.image = newImageIcon
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        self.mailIconImageView.alpha = 1
      })
    }
  }

  func indexStateChanged(notification: NSNotification) {
    let newImageIcon = Global.isIndexOpen ? UIImage(named: "closeIcon") : UIImage(named: "hamburgerIcon")
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.indexIconImageView.alpha = 0
    }) { (completed) -> Void in
      self.indexIconImageView.image = newImageIcon
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        self.indexIconImageView.alpha = 1
      })
    }
  }

}
