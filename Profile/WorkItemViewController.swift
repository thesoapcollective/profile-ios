//
//  WorkItemViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 1/3/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit

class WorkItemViewController: ItemViewController {

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()
    descriptionTopConstraint.constant = -view.frame.height
  }

  func panDescriptionView(dy: CGFloat) {
    let newOffsetY: CGFloat = descriptionTopConstraint.constant + dy
    if newOffsetY >= 0 {
      descriptionTopConstraint.constant = 0
    } else if newOffsetY <= -view.frame.height {
      descriptionTopConstraint.constant = -view.frame.height
    } else {
      descriptionTopConstraint.constant = newOffsetY
    }
    view.layoutIfNeeded()
  }

  // ==================================================
  // NOTIFICATIONS
  // ==================================================

  override func scrollChanged(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let dy = userInfo["dy"] as! CGFloat
    let panDy = userInfo["panDy"] as! CGFloat
    let currentDirection = UIPanGestureRecognizerDirection(rawValue: userInfo["currentDirection"] as! Int)
    let currentIndex = userInfo["currentIndex"] as! Int
    let currentStage = userInfo["currentStage"] as! Int
    let threshold = view.frame.height
    let fadingOutAlpha: CGFloat = (threshold - abs(panDy)) / threshold
    let fadingInAlpha: CGFloat = 1 - fadingOutAlpha

    if currentDirection == .Up {
      if currentIndex + 1 == index { // Panning up back to this index
        // Do nothing.
      } else if currentIndex == index { // Panning up on this index
        if currentStage == 0 { // Panning up on this index to next index
          gradientContainerView.alpha = fadingOutAlpha
          photoImageView.alpha = fadingOutAlpha
          shortTitleLabel.alpha = fadingOutAlpha
        } else { // Panning up on this index to stage 0
          panDescriptionView(dy)
          descriptionContainerView.alpha = fadingOutAlpha
          photoGrayscaleImageView.alpha = Global.PhotoGrayscaleOpacity * fadingOutAlpha
          photoImageView.alpha = fadingInAlpha
          shortTitleLabel.alpha = fadingInAlpha
        }
      }
    } else if currentDirection == .Down {
      if currentIndex - 1 == index { // Panning down to this index
        gradientContainerView.alpha = fadingInAlpha
        photoImageView.alpha = fadingInAlpha
        shortTitleLabel.alpha = fadingInAlpha
      } else if currentIndex == index { // Panning down on this index
        if currentStage == 0 { // Panning down on this index to stage 1
          panDescriptionView(dy)
          descriptionContainerView.alpha = fadingInAlpha
          photoGrayscaleImageView.alpha = Global.PhotoGrayscaleOpacity * fadingInAlpha
          photoImageView.alpha = fadingOutAlpha
          shortTitleLabel.alpha = fadingOutAlpha
        } else { // Panning down on this index to previous index
          // Do nothing.
        }
      }
    }
  }

  override func scrollEnded(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let currentIndex = userInfo["currentIndex"] as! Int
    let currentStage = userInfo["currentStage"] as! Int
    var alpha: CGFloat!
    var stage0Alpha: CGFloat!
    var stage1Alpha: CGFloat!
    var descriptionTopConstraint: CGFloat!

    if currentIndex + 1 == index {
      alpha = 1
      stage0Alpha = 0
      stage1Alpha = Global.PhotoGrayscaleOpacity
      descriptionTopConstraint = 0
    } else if currentIndex - 1 == index {
      alpha = 0
      stage0Alpha = 0
      stage1Alpha = 0
      descriptionTopConstraint = 0
    } else {
      alpha = 1
      stage0Alpha = currentStage == 0 ? 1 : 0
      stage1Alpha = currentStage == 1 ? Global.PhotoGrayscaleOpacity : 0
      descriptionTopConstraint = currentStage == 0 ? -view.frame.height : 0
    }

    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.descriptionContainerView.alpha = alpha
      self.gradientContainerView.alpha = alpha
      self.photoGrayscaleImageView.alpha = stage1Alpha
      self.photoImageView.alpha = stage0Alpha
      self.shortTitleLabel.alpha = stage0Alpha
    })

    view.layoutIfNeeded()
    UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.descriptionTopConstraint.constant = descriptionTopConstraint
      self.view.layoutIfNeeded()
      }, completion: nil)
  }

}