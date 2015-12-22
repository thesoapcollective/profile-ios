//
//  UIPanGestureRecognizer.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

enum UIPanGestureRecognizerDirection {
  case None
  case Left
  case Right
  case Up
  case Down
  case LeftUp
  case LeftDown
  case RightUp
  case RightDown
}

extension UIPanGestureRecognizer {

  func direction(view: UIView?) -> UIPanGestureRecognizerDirection {
    let velocity = velocityInView(view)

    if velocity.x == 0 {
      if velocity.y < 0 {
        return .Up
      } else if velocity.y > 0 {
        return .Down
      }
    }

    if velocity.x < 0 {
      if velocity.y < 0 {
        return .LeftUp
      } else if velocity.y > 0 {
        return .LeftDown
      } else {
        return .Left
      }
    } else if velocity.x > 0 {
      if velocity.y < 0 {
        return .RightUp
      } else if velocity.y > 0 {
        return .RightDown
      } else {
        return .Right
      }
    }

    return .None
  }

}