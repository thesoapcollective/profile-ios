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

}