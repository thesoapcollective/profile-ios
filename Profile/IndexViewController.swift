//
//  IndexViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/22/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

class IndexViewController: PROViewController {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var teamLabel: UILabel!
  @IBOutlet weak var workLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!

  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

  weak var delegate: ContainerViewController!

  var items: [[String: String]] {
    var uniqueItems = [[String: String]]()
    for (i, item) in delegate.items.enumerate() {
      let index = uniqueItems.indexOf({ $0["title"] == item["title"] })
      if index == nil {
        var indexedItem = item
        indexedItem["index"] = String(i)
        uniqueItems.append(indexedItem)
      }
    }
    return uniqueItems
  }

  // ==================================================
  // METHODS
  // ==================================================

  override func updateColors() {
    view.backgroundColor = UIColor.appInvertedPrimaryBackgroundColor()
    teamLabel.textColor = UIColor.appInvertedSecondaryTextColor()
    workLabel.textColor = UIColor.appInvertedSecondaryTextColor()
    tableView.reloadData()
  }

}

extension IndexViewController: UITableViewDelegate {}

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

    cell.titleLabel.text = item["title"]
    if indexPath.row == delegate.homeIndex {
      cell.iconImageView.image = UIImage(named: "homeIcon")?.imageWithRenderingMode(.AlwaysTemplate)
    } else if let iconName = item["icon"] {
      cell.iconImageView.image = UIImage(named: iconName)
    }
    cell.iconDottedBorderView.hidden = item["index"] != String(delegate.currentIndex)
    cell.bottomDottedBorderView.hidden = item["index"] == String(delegate.items.count - 1)

    cell.tintColor = UIColor.appInvertedPrimaryTextColor()
    cell.titleLabel.textColor = UIColor.appInvertedPrimaryTextColor()
    cell.bottomDottedBorderView.dotColor = UIColor.appInvertedPrimaryTextColor()
    cell.iconDottedBorderView.dotColor = UIColor.appInvertedPrimaryTextColor()

    return cell
  }

}