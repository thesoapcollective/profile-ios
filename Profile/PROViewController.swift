//
//  PROViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/23/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

class PROViewController: UIViewController {

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNotifcations()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    updateColors()
  }

  func updateColors() {
    // Override this to do stuff...
  }

  // ==================================================
  // NOTIFICATIONS
  // ==================================================

  func setupNotifcations() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "profileModeChanged:", name: Global.ProfileModeChangedNotification, object: nil)
  }

  func profileModeChanged(notification: NSNotification) {
    updateColors()
  }

}
