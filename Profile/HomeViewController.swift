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

  @IBOutlet weak var bottomGradientView: LinearGradientView!
  @IBOutlet weak var descriptionContainerView: ParallaxView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var radialGradientContainerView: UIView!
  @IBOutlet weak var radialGradientView: RadialGradientView!
  @IBOutlet weak var logoImageView: ParallaxImageView!
  @IBOutlet weak var topGradientView: LinearGradientView!

  @IBOutlet weak var radialGradientTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var radialGradientTrailingConstraint: NSLayoutConstraint!

  let DayDescription = "The Soap Collective is a multi-media creative agency. We focus on building high-end interactive experiences that connect people and inspire emotion."
  let NighDescription = "Looks like you found Side B... Scroll through in this mode to get behind the scenes trivia about our projects and team."

  var index = 0
  var isDescriptionShowing = false

  var descriptionTapGesture: UITapGestureRecognizer!
  var logoTapGesture: UITapGestureRecognizer!

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()

    descriptionContainerView.layer.borderWidth = 1
    logoImageView.image = logoImageView.image?.imageWithRenderingMode(.AlwaysTemplate)

    setModeDependentAttributes()
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

  override func profileModeChanged(notification: NSNotification) {
    super.profileModeChanged(notification)
    setModeDependentAttributes()
  }

  override func updateColors() {
    view.backgroundColor = UIColor.appPrimaryBackgroundColor()
    bottomGradientView.fromColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(0)
    bottomGradientView.toColor = UIColor.appPrimaryBackgroundColor()
    descriptionLabel.textColor = UIColor.appPrimaryTextColor()
    descriptionContainerView.layer.borderColor = UIColor.appPrimaryTextColor().colorWithAlphaComponent(0.75).CGColor
    logoImageView.tintColor = UIColor.appPrimaryTextColor()
    radialGradientView.fromColor = UIColor.appInvertedPrimaryBackgroundColor()
    radialGradientView.toColor = UIColor.appInvertedPrimaryBackgroundColor().colorWithAlphaComponent(0)
    topGradientView.fromColor = UIColor.appPrimaryBackgroundColor()
    topGradientView.toColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(0)
  }

  func addParallaxToViews() {
    radialGradientView.addParallax(Global.ParallaxOffset2)
    logoImageView.addParallax(Global.ParallaxOffset1)
    descriptionContainerView.addParallax(Global.ParallaxOffset1)
  }

  func removeParallaxFromViews() {
    logoImageView.removeParallax()
    radialGradientView.removeParallax()
  }

  func setModeDependentAttributes() {
    descriptionLabel.text = Global.mode == .Light ? DayDescription : NighDescription
  }

  func toggleDescription() {
    if isDescriptionShowing {
      UIView.animateWithDuration(0.3, animations: { () -> Void in
        self.descriptionContainerView.alpha = 0
      }, completion: { (completed) -> Void in
        UIView.animateWithDuration(0.3, animations: { () -> Void in
          self.logoImageView.alpha = 1
        }, completion: { (completed) -> Void in
          self.isDescriptionShowing = false
        })
      })
    } else {
      UIView.animateWithDuration(0.3, animations: { () -> Void in
        self.logoImageView.alpha = 0
      }, completion: { (completed) -> Void in
        UIView.animateWithDuration(0.3, animations: { () -> Void in
          self.descriptionContainerView.alpha = 1
        }, completion: { (completed) -> Void in
          self.isDescriptionShowing = true
        })
      })
    }
  }

  // ==================================================
  // GESTURES
  // ==================================================

  func setupGestures() {
    descriptionTapGesture = UITapGestureRecognizer(target: self, action: "descriptionTapped:")
    descriptionContainerView.addGestureRecognizer(descriptionTapGesture)

    logoTapGesture = UITapGestureRecognizer(target: self, action: "logoTapped:")
    logoImageView.addGestureRecognizer(logoTapGesture)
  }

  func descriptionTapped(notification: NSNotification) {
    toggleDescription()
  }

  func logoTapped(notification: NSNotification) {
    toggleDescription()
  }

  // ==================================================
  // NOTIFICATIONS
  // ==================================================

  override func setupNotifcations() {
    super.setupNotifcations()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBooted:", name: Global.AppBootedNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "contactPanning:", name: Global.ContactPanningNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "contactStateChanged:", name: Global.ContactStateChanged, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "indexPanning:", name: Global.IndexPanningNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "indexStateChanged:", name: Global.IndexStateChanged, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "internetReachable:", name: Global.InternetReachableNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "internetNotReachable:", name: Global.InternetNotReachableNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollChanged:", name: Global.ScrollChangedNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollEnded:", name: Global.ScrollEndedNotification, object: nil)
  }

  func appBooted(notification: NSNotification) {
    addParallaxToViews()
    setupGestures()
  }

  func contactPanning(notification: NSNotification) {
    removeParallaxFromViews()
  }

  func contactStateChanged(notification: NSNotification) {
    if Global.isContactOpen {
      descriptionTapGesture.enabled = false
      logoTapGesture.enabled = false
      removeParallaxFromViews()
    } else {
      descriptionTapGesture.enabled = true
      logoTapGesture.enabled = true
      addParallaxToViews()
    }
  }

  func indexPanning(notification: NSNotification) {
    removeParallaxFromViews()
  }

  func indexStateChanged(notification: NSNotification) {
    if Global.isIndexOpen {
      descriptionTapGesture.enabled = false
      logoTapGesture.enabled = false
      removeParallaxFromViews()
    } else {
      descriptionTapGesture.enabled = true
      logoTapGesture.enabled = true
      addParallaxToViews()
    }
  }

  func internetReachable(notification: NSNotification) {
    descriptionTapGesture.enabled = true
    logoTapGesture.enabled = true
  }

  func internetNotReachable(notification: NSNotification) {
    descriptionTapGesture.enabled = false
    logoTapGesture.enabled = false
  }

  func scrollChanged(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let panDy = userInfo["panDy"] as! CGFloat
    let currentDirection = UIPanGestureRecognizerDirection(rawValue: userInfo["currentDirection"] as! Int)
    let currentIndex = userInfo["currentIndex"] as! Int
    var threshold: CGFloat = 0
    var alpha: CGFloat = 0

    removeParallaxFromViews()

    if currentIndex == index {
      threshold = view.frame.height / 2
      alpha = (threshold - abs(panDy)) / threshold
    } else {
      threshold = view.frame.height
      alpha = 1 - (threshold - abs(panDy)) / threshold
    }

    logoImageView.alpha = alpha
    radialGradientContainerView.alpha = alpha

    if currentDirection == .Up {
      if currentIndex == index {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
          self.bottomGradientView.alpha = 1
        })
      } else if currentIndex + 1 == index {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
          self.topGradientView.alpha = 1
        })
      }
    } else if currentDirection == .Down {
      if currentIndex == index {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
          self.topGradientView.alpha = 1
        })
      } else if currentIndex - 1 == index {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
          self.bottomGradientView.alpha = 1
        })
      }
    }
  }

  func scrollEnded(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let currentIndex = userInfo["currentIndex"] as! Int
    let alpha: CGFloat = currentIndex == index ? 1 : 0

    if currentIndex == index && Global.isAppBooted {
      addParallaxToViews()
    }

    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.bottomGradientView.alpha = 0
      self.logoImageView.alpha = alpha
      self.radialGradientContainerView.alpha = alpha
      self.topGradientView.alpha = 0
    })
  }

}
