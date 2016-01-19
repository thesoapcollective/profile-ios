//
//  TeamItemViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 1/3/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit

class TeamItemViewController: ItemViewController {

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()

    if index < delegate.items.count - 1 {
      gradientView = LinearGradientView(frame: CGRectZero)
      gradientView?.backgroundColor = UIColor.clearColor()
      view.addSubview(gradientView!)
    }

    itemView.descriptionTopConstraint.constant = view.frame.height
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let gradientHeight: CGFloat = view.frame.height * 173 / 667
    gradientView?.frame = CGRect(x: 0, y: view.frame.height - gradientHeight, width: view.frame.width, height: gradientHeight)
  }

  override func updateColors() {
    super.updateColors()

    gradientView?.fromColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(0)
    gradientView?.toColor = UIColor.appPrimaryBackgroundColor()
  }

  func panDescriptionView(dy: CGFloat) {
    let newOffsetY: CGFloat = itemView.descriptionTopConstraint.constant + dy
    if newOffsetY <= 0 {
      itemView.descriptionTopConstraint.constant = 0
    } else if newOffsetY >= view.frame.height {
      itemView.descriptionTopConstraint.constant = view.frame.height
    } else {
      itemView.descriptionTopConstraint.constant = newOffsetY
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
      if currentIndex + 1 == index { // Panning up to this index
        itemView.gradientContainerView.alpha = fadingInAlpha
        itemView.photoImageView.alpha = fadingInAlpha
        itemView.shortTitleLabel.alpha = fadingInAlpha
      } else if currentIndex == index { // Panning up on this index
        if currentStage == 0 { // Panning up on this index to stage 1
          panDescriptionView(dy)
          itemView.descriptionContainerView.alpha = fadingInAlpha
          itemView.photoGrayscaleImageView.alpha = Global.PhotoGrayscaleOpacity * fadingInAlpha
          itemView.photoImageView.alpha = fadingOutAlpha
          itemView.shortTitleLabel.alpha = fadingOutAlpha
        } else { // Panning up on this index to next index
          // Do nothing.
        }
      }
    } else if currentDirection == .Down {
      if currentIndex - 1 == index { // Panning down back to this index
        // Do nothing.
      } else if currentIndex == index { // Panning down on this index
        if currentStage == 0 { // Panning down on this index to previous index
          itemView.gradientContainerView.alpha = fadingOutAlpha
          itemView.photoImageView.alpha = fadingOutAlpha
          itemView.shortTitleLabel.alpha = fadingOutAlpha
        } else { // Panning down on this index to stage 0
          panDescriptionView(dy)
          itemView.descriptionContainerView.alpha = fadingOutAlpha
          itemView.photoGrayscaleImageView.alpha = Global.PhotoGrayscaleOpacity * fadingOutAlpha
          itemView.photoImageView.alpha = fadingInAlpha
          itemView.shortTitleLabel.alpha = fadingInAlpha
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
      alpha = 0
      stage0Alpha = 0
      stage1Alpha = 0
      descriptionTopConstraint = 0
    } else if currentIndex - 1 == index {
      alpha = 1
      stage0Alpha = 0
      stage1Alpha = Global.PhotoGrayscaleOpacity
      descriptionTopConstraint = 0
    } else {
      alpha = 1
      stage0Alpha = currentStage == 0 ? 1 : 0
      stage1Alpha = currentStage == 1 ? Global.PhotoGrayscaleOpacity : 0
      descriptionTopConstraint = currentStage == 0 ? view.frame.height : 0
    }

    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.itemView.descriptionContainerView.alpha = alpha
      self.itemView.gradientContainerView.alpha = alpha
      self.itemView.photoGrayscaleImageView.alpha = stage1Alpha
      self.itemView.photoImageView.alpha = stage0Alpha
      self.itemView.shortTitleLabel.alpha = stage0Alpha
    })

    view.layoutIfNeeded()
    UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.itemView.descriptionTopConstraint.constant = descriptionTopConstraint
      self.view.layoutIfNeeded()
    }, completion: nil)
  }

}