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

  @IBOutlet weak var radialGradientContainerView: UIView!
  @IBOutlet weak var radialGradientView: RadialGradientView!
  @IBOutlet weak var indexIconContainerView: UIView!
  @IBOutlet weak var indexIconImageView: UIImageView!
  @IBOutlet weak var indexIconDottedBorderImageView: DottedBorderImageView!
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var mailIconContainerView: UIView!
  @IBOutlet weak var mailIconImageView: UIImageView!
  @IBOutlet weak var mailIconDottedBorderImageView: DottedBorderImageView!

  @IBOutlet weak var radialGradientTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var radialGradientTrailingConstraint: NSLayoutConstraint!

  var index = 0

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()

    logoImageView.image = logoImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    indexIconImageView.image = indexIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    mailIconImageView.image = mailIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)

    setupGestures()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if UIDevice.currentDevice().orientation == .Portrait || UIDevice.currentDevice().orientation == .PortraitUpsideDown {
      let gradientOffset: CGFloat = -view.frame.width * 0.9
      radialGradientTopConstraint.constant = gradientOffset
      radialGradientTrailingConstraint.constant = gradientOffset
      view.layoutIfNeeded()
    }
  }

  override func updateColors() {
    logoImageView.tintColor = UIColor.appPrimaryTextColor()
    indexIconImageView.tintColor = UIColor.appPrimaryTextColor()
    indexIconDottedBorderImageView.dotColor = UIColor.appPrimaryTextColor()
    mailIconImageView.tintColor = UIColor.appPrimaryTextColor()
    mailIconDottedBorderImageView.dotColor = UIColor.appPrimaryTextColor()
    radialGradientView.fromColor = UIColor.appInvertedPrimaryBackgroundColor()
    radialGradientView.toColor = UIColor.appInvertedPrimaryBackgroundColor().colorWithAlphaComponent(0)
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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollChanged:", name: Global.ScrollChangedNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollEnded:", name: Global.ScrollEndedNotification, object: nil)
  }

  func contactStateChanged(notification: NSNotification) {
    let newImageIcon = Global.isContactOpen ? UIImage(named: "closeIcon") : UIImage(named: "mailIcon")
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.mailIconImageView.alpha = 0
    }) { (completed) -> Void in
      self.mailIconImageView.image = newImageIcon?.imageWithRenderingMode(.AlwaysTemplate)
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
      self.indexIconImageView.image = newImageIcon?.imageWithRenderingMode(.AlwaysTemplate)
      UIView.animateWithDuration(0.5, animations: { () -> Void in
        self.indexIconImageView.alpha = 1
      })
    }
  }

  func scrollChanged(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let panDy = userInfo["panDy"] as! CGFloat
    let currentIndex = userInfo["currentIndex"] as! Int
    var threshold: CGFloat = 0
    var alpha: CGFloat = 0

    if currentIndex == index {
      threshold = view.frame.height / 2
      alpha = (threshold - abs(panDy)) / threshold
    } else {
      threshold = view.frame.height
      alpha = 1 - (threshold - abs(panDy)) / threshold
    }

    radialGradientContainerView.alpha = alpha
    indexIconContainerView.alpha = alpha
    logoImageView.alpha = alpha
    mailIconContainerView.alpha = alpha
  }

  func scrollEnded(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let currentIndex = userInfo["currentIndex"] as! Int
    let alpha: CGFloat =  currentIndex == index ? 1 : 0

    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.radialGradientContainerView.alpha = alpha
      self.indexIconContainerView.alpha = alpha
      self.logoImageView.alpha = alpha
      self.mailIconContainerView.alpha = alpha
    })
  }

}
