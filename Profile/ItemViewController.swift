//
//  ItemViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

class ItemViewController: PROViewController {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var label: UILabel!

  var data: [String: String]! {
    didSet {
      setupData()
    }
  }

  // ==================================================
  // METHODS
  // ==================================================

  func setupData() {
    label.text = data["title"]
  }

  override func updateColors() {
    view.backgroundColor = UIColor.appPrimaryBackgroundColor()
  }

}