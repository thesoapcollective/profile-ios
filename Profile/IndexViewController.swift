//
//  IndexViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/22/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import AlamofireImage
import UIKit
import SwiftyJSON

class IndexViewController: PROViewController {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var teamLabel: UILabel!
  @IBOutlet weak var workLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!

  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

  weak var delegate: ContainerViewController!

  var items = [JSON]()

  // ==================================================
  // METHODS
  // ==================================================

  override func updateColors() {
    view.backgroundColor = UIColor.appInvertedPrimaryBackgroundColor()
    teamLabel.textColor = UIColor.appInvertedSecondaryTextColor()
    workLabel.textColor = UIColor.appInvertedSecondaryTextColor()
    tableView.reloadData()
  }

  override func profileModeChanged(notification: NSNotification) {
    super.profileModeChanged(notification)
    tableView.reloadData()
    toggleCurrentIndexAnimation()
  }

  func toggleCurrentIndexAnimation() {
    for (i, item) in items.enumerate() {
      if item["indexes"].arrayValue.contains(JSON(delegate.currentIndex)) {
        guard let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? IndexTableViewCell else { return }
        Global.isIndexOpen ? cell.startAnimation() : cell.stopAnimation()
        break
      }
    }
  }

  // ==================================================
  // NOTIFICATIONS
  // ==================================================

  override func setupNotifcations() {
    super.setupNotifcations()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataLoaded:", name: Global.DataLoaded, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "indexStateChanged:", name: Global.IndexStateChanged, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollEnded:", name: Global.ScrollEndedNotification, object: nil)
  }

  func dataLoaded(notification: NSNotification) {
    for (i, item) in delegate.items.enumerate() {
      if let index = items.indexOf({ $0["title"].stringValue == item["title"].stringValue }) {
        items[index]["indexes"].arrayObject = items[index]["indexes"].arrayObject! + [i]
      } else {
        var indexedItem = item
        indexedItem["indexes"].arrayObject = [i]
        items.append(indexedItem)
      }
    }
    tableView.reloadData()
  }

  func indexStateChanged(notification: NSNotification) {
    toggleCurrentIndexAnimation()
  }

  func orientationChanged(notification: NSNotification) {
    switch UIDevice.currentDevice().orientation {
    case .Portrait:
      if Global.mode != .Light {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
          self.view.alpha = 0
        }) { (completed) -> Void in
          UIView.animateWithDuration(0.5, delay: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            self.view.alpha = 1
          }, completion: nil)
        }
      }
      break
    case .PortraitUpsideDown:
      if Global.mode != .Dark {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
          self.view.alpha = 0
        }) { (completed) -> Void in
          UIView.animateWithDuration(0.5, delay: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            self.view.alpha = 1
          }, completion: nil)
        }
      }
      break
    default:
      break
    }
  }

  func scrollEnded(notification: NSNotification) {
    tableView.reloadData()
  }

}

extension IndexViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let item = items[indexPath.row]
    for (i, delegateItem) in delegate.items.enumerate() {
      if delegateItem["title"].stringValue == item["title"].stringValue {
        delegate.openCloseIndex(false, animated: true, completion: { [unowned self] () -> Void in
          self.delegate.currentIndex = i
          self.delegate.currentStage = 0
          self.delegate.snapContent(true)
          NSNotificationCenter.defaultCenter().postNotificationName(
            Global.ScrollEndedNotification,
            object: nil,
            userInfo: [
              "dy": 0,
              "panDy": 0,
              "dyThreshold": 0,
              "currentDirection": 0,
              "currentIndex": i,
              "currentStage": 0
            ]
          )
        })
        break
      }
    }
  }

}

extension IndexViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = items.count
    if tableViewHeightConstraint != nil {
      tableViewHeightConstraint.constant = CGFloat(count * 42)
    }
    return count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("IndexTableViewCell", forIndexPath: indexPath) as! IndexTableViewCell
    let item = items[indexPath.row]

    cell.titleLabel.text = item["index_title"].stringValue
    let iconUrl = Global.mode == .Light ? item["day_icon_url"].stringValue : item["night_icon_url"].stringValue
    if indexPath.row == delegate.homeIndex {
      cell.iconImageView.image = UIImage(named: "homeIcon")?.imageWithRenderingMode(.AlwaysTemplate)
    } else if let imageUrl = NSURL(string: iconUrl) {
      cell.iconImageView.af_setImageWithURL(imageUrl, imageTransition: .CrossDissolve(0.3))
    }
    cell.bottomDottedBorderView.hidden = item["indexes"].arrayValue.contains(JSON(delegate.items.count - 1))

    if item["indexes"].arrayValue.contains(JSON(delegate.currentIndex)) {
      cell.iconDottedBorderView.hidden = false
      cell.titleLabel.font = UIFont(name: "FuturaPt-Heavy", size: cell.titleLabel.font.pointSize)
    } else {
      cell.iconDottedBorderView.hidden = true
      cell.titleLabel.font = UIFont(name: "FuturaPt-Book", size: cell.titleLabel.font.pointSize)
    }

    cell.tintColor = UIColor.appInvertedPrimaryTextColor()
    cell.titleLabel.textColor = UIColor.appInvertedPrimaryTextColor()
    cell.bottomDottedBorderView.dotColor = UIColor.appInvertedPrimaryTextColor()
    cell.iconDottedBorderView.dotColor = UIColor.appInvertedPrimaryTextColor()

    return cell
  }

}