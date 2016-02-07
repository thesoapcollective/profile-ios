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

    itemView.descriptionTopConstraint.constant = -view.frame.height
    itemView.descriptionGradientBottomConstraint.constant = view.frame.height - itemView.descriptionGradientView.frame.height
    itemView.topGradientView.hidden = index <= 0
    itemView.topGradientTopConstraint.constant = -view.frame.height
  }

  override func updateColors() {
    super.updateColors()

    itemView.topGradientView.fromColor = UIColor.appPrimaryBackgroundColor()
    itemView.topGradientView.toColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(0)
    itemView.bottomGradientView.fromColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(0)
    itemView.bottomGradientView.toColor = UIColor.appPrimaryBackgroundColor()
    itemView.descriptionGradientView.fromColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(0.9)
    itemView.descriptionGradientView.toColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(0)
  }

  func panDescriptionView(dy: CGFloat) {
    let newOffsetY: CGFloat = itemView.descriptionTopConstraint.constant + dy
    if newOffsetY >= 0 {
      itemView.descriptionGradientBottomConstraint.constant = -itemView.descriptionGradientView.frame.height
      itemView.descriptionTopConstraint.constant = 0
      itemView.topGradientTopConstraint.constant = -view.frame.height
      if let arrowConstraintStage0 = self.delegate.continueArrowConstraints["itemView\(self.index)-stage0"] {
        arrowConstraintStage0.constant = -Global.WorkArrowOffset
      }
    } else if newOffsetY <= -view.frame.height {
      itemView.descriptionGradientBottomConstraint.constant = view.frame.height - itemView.descriptionGradientView.frame.height
      itemView.descriptionTopConstraint.constant = -view.frame.height
      itemView.topGradientTopConstraint.constant = 0
      if let arrowConstraintStage0 = self.delegate.continueArrowConstraints["itemView\(self.index)-stage0"] {
        arrowConstraintStage0.constant = -Global.WorkArrowOffset + view.frame.height
      }
    } else {
      itemView.descriptionGradientBottomConstraint.constant = itemView.descriptionGradientBottomConstraint.constant - dy
      itemView.descriptionTopConstraint.constant = newOffsetY
      itemView.topGradientTopConstraint.constant = itemView.topGradientTopConstraint.constant + dy
      if let arrowConstraintStage0 = self.delegate.continueArrowConstraints["itemView\(self.index)-stage0"] {
        arrowConstraintStage0.constant = arrowConstraintStage0.constant + dy
      }
    }
    view.layoutIfNeeded()
    delegate.view.layoutIfNeeded()
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
      } else if currentIndex - 1 == index { // Panning up away from this index
        if currentStage == 1 {
          if let arrowConstraintStage0 = self.delegate.continueArrowConstraints["itemView\(self.index)-stage0"] {
            arrowConstraintStage0.constant = arrowConstraintStage0.constant + dy
            delegate.view.layoutIfNeeded()
          }
        }
      } else if currentIndex == index { // Panning up on this index
        if currentStage == 0 { // Panning up on this index to next index
          itemView.radialGradientContainerView.alpha = fadingOutAlpha
          itemView.photoImageView.alpha = fadingOutAlpha
          itemView.shortTitleLabel.alpha = fadingOutAlpha
          UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.itemView.bottomGradientView.alpha = 1
          })
        } else { // Panning up on this index to stage 0
          panDescriptionView(dy)
          itemView.descriptionContainerView.alpha = fadingOutAlpha
          itemView.photoGrayscaleImageView.alpha = fadingOutAlpha
          itemView.photoImageView.alpha = fadingInAlpha
          itemView.shortTitleLabel.alpha = fadingInAlpha
        }
      }
    } else if currentDirection == .Down {
      if currentIndex - 1 == index { // Panning down to this index
        itemView.radialGradientContainerView.alpha = fadingInAlpha
        itemView.photoImageView.alpha = fadingInAlpha
        itemView.shortTitleLabel.alpha = fadingInAlpha
      } else if currentIndex == index { // Panning down on this index
        if currentStage == 0 { // Panning down on this index to stage 1
          panDescriptionView(dy)
          itemView.descriptionContainerView.alpha = fadingInAlpha
          itemView.photoGrayscaleImageView.alpha = fadingInAlpha
          itemView.photoImageView.alpha = fadingOutAlpha
          itemView.shortTitleLabel.alpha = fadingOutAlpha
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
    var bottomGradientAlpha: CGFloat!
    var arrowStage0Constraint: CGFloat!
    var descriptionTopConstraint: CGFloat!
    var descriptionGradientBottomConstraint: CGFloat!
    var topGradientConstraint: CGFloat!

    updateImage()

    if currentIndex + 1 == index {
      alpha = 1
      bottomGradientAlpha = 0
      stage0Alpha = 0
      stage1Alpha = 1
      arrowStage0Constraint = -Global.WorkArrowOffset + view.frame.height
      descriptionTopConstraint = 0
      descriptionGradientBottomConstraint = -itemView.descriptionGradientView.frame.height
      topGradientConstraint = 0
    } else if currentIndex - 1 == index {
      alpha = 0
      bottomGradientAlpha = 1
      stage0Alpha = 0
      stage1Alpha = 0
      if currentIndex == delegate.homeIndex {
        arrowStage0Constraint = -Global.WorkArrowOffset
      } else {
        arrowStage0Constraint = currentStage == 0 ? -Global.WorkArrowOffset - view.frame.height : -Global.WorkArrowOffset
      }
      descriptionTopConstraint = -view.frame.height
      descriptionGradientBottomConstraint = view.frame.height - itemView.descriptionGradientView.frame.height
      topGradientConstraint = -view.frame.height
    } else {
      alpha = 1
      bottomGradientAlpha = 0
      stage0Alpha = currentStage == 0 ? 1 : 0
      stage1Alpha = currentStage == 1 ? 1 : 0
      if currentIndex == index {
        arrowStage0Constraint = currentStage == 0 ? -Global.WorkArrowOffset : -Global.WorkArrowOffset + view.frame.height
      } else {
        arrowStage0Constraint = -Global.WorkArrowOffset
      }
      descriptionTopConstraint = currentStage == 0 ? -view.frame.height : 0
      descriptionGradientBottomConstraint = currentStage == 0 ? view.frame.height - itemView.descriptionGradientView.frame.height : -itemView.descriptionGradientView.frame.height
      topGradientConstraint = currentStage == 0 ? -view.frame.height : 0
    }

    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.itemView.descriptionContainerView.alpha = alpha
      self.itemView.radialGradientContainerView.alpha = alpha
      self.itemView.photoGrayscaleImageView.alpha = stage1Alpha
      self.itemView.photoImageView.alpha = stage0Alpha
      self.itemView.shortTitleLabel.alpha = stage0Alpha
      self.itemView.bottomGradientView.alpha = bottomGradientAlpha
    })

    view.layoutIfNeeded()
    UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.itemView.descriptionTopConstraint.constant = descriptionTopConstraint
      self.itemView.descriptionGradientBottomConstraint.constant = descriptionGradientBottomConstraint
      self.itemView.topGradientTopConstraint.constant = topGradientConstraint
      if let arrowConstraintStage0 = self.delegate.continueArrowConstraints["itemView\(self.index)-stage0"] {
        arrowConstraintStage0.constant = arrowStage0Constraint
      }
      self.view.layoutIfNeeded()
      self.delegate.view.layoutIfNeeded()
    }, completion: nil)
  }

}