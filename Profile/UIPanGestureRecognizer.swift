//
//  UIPanGestureRecognizer.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

enum UIPanGestureRecognizerDirection: Int {
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

    if abs(velocity.x) > abs(velocity.y) { // Horizontal pan
      if velocity.x < 0 {
        return .Left
      } else if velocity.x > 0 {
        return .Right
      }
    } else if abs(velocity.y) > abs(velocity.x) { // Veritcal pan
      if velocity.y < 0 {
        return .Up
      } else if velocity.y > 0 {
        return .Down
      }
    } else if abs(velocity.x) == abs(velocity.y) && velocity.x != 0 && velocity.y != 0 { // Diagonal pan
      if velocity.y < 0 {
        if velocity.x < 0 {
          return .LeftUp
        } else if velocity.x > 0 {
          return .RightUp
        }
      } else if velocity.y > 0 {
        if velocity.x < 0 {
          return .LeftDown
        } else if velocity.x > 0 {
          return .RightDown
        }
      }
    }

    return .None
  }

}