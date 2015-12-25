//
//  HomeViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/23/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

class HomeViewController: PROViewController {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var logoImageView: UIImageView!

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()
    logoImageView.image = logoImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
  }

  override func updateColors() {
    logoImageView.tintColor = UIColor.appPrimaryTextColor()
  }

}
