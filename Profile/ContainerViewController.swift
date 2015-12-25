//
//  ContainerViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

class ContainerViewController: PROViewController {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var contactView: UIView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var indexView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!

  @IBOutlet weak var contactViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var indexViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollViewTrailingConstraint: NSLayoutConstraint!

  var currentIndex = 0

  var isContactOpen = false
  var isIndexOpen = false

  var isPanningContact = false
  var isPanningContent = false
  var isPanningIndex = false

  var panDx: CGFloat = 0
  var panDy: CGFloat = 0

  var items = [
    ["title": "Home"]
  ]
  var itemViewControllers = [UIViewController]()

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()

    contactViewTrailingConstraint.constant = isContactOpen ? 0 : -contactView.frame.width
    indexViewLeadingConstraint.constant = isIndexOpen ? 0 : -indexView.frame.width

    setupData()
    setupInitialViewControllers()
    setupGestures()
    setupNotifcations()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    snapContent(false)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if UIDevice.currentDevice().orientation == .Portrait || UIDevice.currentDevice().orientation == .PortraitUpsideDown {
      contentHeightConstraint.constant = view.frame.height * CGFloat(items.count)
      view.layoutIfNeeded()
      for (i, itemViewController) in itemViewControllers.enumerate() {
        itemViewController.view.frame = CGRect(x: 0, y: view.frame.height * CGFloat(i), width: view.frame.width, height: view.frame.height)
      }
    }
  }

  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return .All
  }

  override func shouldAutorotate() -> Bool {
    return UIDevice.currentDevice().orientation == .Portrait ||
           UIDevice.currentDevice().orientation == .PortraitUpsideDown
  }

  func setupData() {
    setupWorkData()
    setupTeamData()
  }

  func setupWorkData() {
    guard let path = NSBundle.mainBundle().pathForResource("WorkData", ofType: "plist") else { return }
    guard let dataArray = NSArray(contentsOfFile: path) else { return }

    for d in dataArray {
      let data = d as! NSDictionary
      items.insert(data as! [String: String], atIndex: 0)
    }

    currentIndex = dataArray.count
  }

  func setupTeamData() {
    guard let path = NSBundle.mainBundle().pathForResource("TeamData", ofType: "plist") else { return }
    guard let dataArray = NSArray(contentsOfFile: path) else { return }

    for d in dataArray {
      let data = d as! NSDictionary
      items.append(data as! [String: String])
    }
  }

  func setupInitialViewControllers() {
    for item in items {
      if item["title"] != "Home" {
        let itemViewController = UIStoryboard.itemViewController()
        contentView.addSubview(itemViewController.view)
        addChildViewController(itemViewController)
        itemViewController.didMoveToParentViewController(self)
        itemViewController.data = item
        itemViewControllers.append(itemViewController)
      } else {
        let itemViewController = UIStoryboard.homeViewController()
        contentView.addSubview(itemViewController.view)
        addChildViewController(itemViewController)
        itemViewController.didMoveToParentViewController(self)
        itemViewControllers.append(itemViewController)
      }
    }
  }

  override func updateColors() {
    view.backgroundColor = UIColor.appPrimaryBackgroundColor()
  }

  // ==================================================
  // CONTACT / INDEX
  // ==================================================

  func snapContent(animated: Bool) {
    let duration = animated ? 0.3 : 0
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.scrollView.setContentOffset(CGPoint(x: 0, y: self.view.frame.height * CGFloat(self.currentIndex)), animated: false)
    }, completion: nil)
  }

  func openCloseContact(open: Bool, animated: Bool) {
    let duration = animated ? 0.3 : 0
    isContactOpen = open
    view.layoutIfNeeded()
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.contactViewTrailingConstraint.constant = open ? 0 : -self.contactView.frame.width
      self.scrollViewLeadingConstraint.constant = open ? -self.contactView.frame.width : 0
      self.scrollViewTrailingConstraint.constant = open ? self.contactView.frame.width : 0
      self.view.layoutIfNeeded()
    }, completion: nil)
  }

  func openCloseIndex(open: Bool, animated: Bool) {
    let duration = animated ? 0.3 : 0
    isIndexOpen = open
    view.layoutIfNeeded()
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.indexViewLeadingConstraint.constant = open ? 0 : -self.indexView.frame.width
      self.scrollViewLeadingConstraint.constant = open ? self.indexView.frame.width : 0
      self.scrollViewTrailingConstraint.constant = open ? -self.indexView.frame.width : 0
      self.view.layoutIfNeeded()
    }, completion: nil)
  }

  // ==================================================
  // GESTURES
  // ==================================================

  func setupGestures() {
    let panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
    view.addGestureRecognizer(panGesture)
  }

  func handlePan(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translationInView(view)
    let dx = translation.x
    let dy = translation.y
    gesture.setTranslation(CGPointZero, inView: view)

    switch gesture.state {
    case .Began:
      panDx = 0
      panDy = 0

      switch gesture.direction(view) {
      case .Left:
        if isIndexOpen {
          isPanningIndex = true
        } else {
          isPanningContact = true
        }
        break
      case .Right:
        if isContactOpen {
          isPanningContact = true
        } else {
          isPanningIndex = true
        }
        break
      case .Up, .Down:
        isPanningContent = !isIndexOpen && !isContactOpen
      default:
        break
      }

      break

    case .Changed:
      panDx += dx
      panDy += dy

      if isPanningContent {
        panContentView(dy)
      } else if isPanningContact {
        panContactView(dx)
      } else if isPanningIndex {
        panIndexView(dx)
      }

      break

    case .Ended:
      let dxThreshold = abs(panDx) >= view.frame.width / 4
      let dyThreshold = abs(panDy) >= view.frame.height / 4

      if isPanningContent {
        if !dyThreshold {
          snapContent(true)
        } else {
          let direction: UIPanGestureRecognizerDirection = gesture.direction(view)
          if direction == .Up || direction == .LeftUp || direction == .RightUp {
            let nextIndex = currentIndex + 1
            currentIndex = nextIndex >= items.count ? items.count - 1 : nextIndex
            snapContent(true)
          } else {
            let previousIndex = currentIndex - 1
            currentIndex = previousIndex <= 0 ? 0 : previousIndex
            snapContent(true)
          }
        }
      } else if isPanningContact {
        let open = dxThreshold ? !isContactOpen : isContactOpen
        openCloseContact(open, animated: true)
      } else if isPanningIndex {
        let open = dxThreshold ? !isIndexOpen : isIndexOpen
        openCloseIndex(open, animated: true)
      }

      isPanningContent = false
      isPanningContact = false
      isPanningIndex = false

      break

    default:
      break
    }
  }

  func panContentView(dy: CGFloat) {
    let newOffsetY: CGFloat = scrollView.contentOffset.y - dy
    let endOffsetY = contentView.frame.height - view.frame.height
    if newOffsetY <= 0 {
      scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    } else if newOffsetY >= endOffsetY {
      scrollView.setContentOffset(CGPoint(x: 0, y: endOffsetY), animated: false)
    } else {
      scrollView.setContentOffset(CGPoint(x: 0, y: newOffsetY), animated: false)
    }
  }

  func panContactView(dx: CGFloat) {
    let newConstant: CGFloat = contactViewTrailingConstraint.constant - dx
    if newConstant >= 0 {
      contactViewTrailingConstraint.constant = 0
      scrollViewLeadingConstraint.constant = -contactView.frame.width
      scrollViewTrailingConstraint.constant = contactView.frame.width
    } else if newConstant <= -contactView.frame.width {
      contactViewTrailingConstraint.constant = -contactView.frame.width
      scrollViewLeadingConstraint.constant = 0
      scrollViewTrailingConstraint.constant = 0
    } else {
      contactViewTrailingConstraint.constant -= dx
      scrollViewLeadingConstraint.constant += dx
      scrollViewTrailingConstraint.constant -= dx
    }
  }

  func panIndexView(dx: CGFloat) {
    let newConstant: CGFloat = indexViewLeadingConstraint.constant + dx
    if newConstant >= 0 {
      indexViewLeadingConstraint.constant = 0
      scrollViewLeadingConstraint.constant = indexView.frame.width
      scrollViewTrailingConstraint.constant = -indexView.frame.width
    } else if newConstant <= -indexView.frame.width {
      indexViewLeadingConstraint.constant = -indexView.frame.width
      scrollViewLeadingConstraint.constant = 0
      scrollViewTrailingConstraint.constant = 0
    } else {
      indexViewLeadingConstraint.constant += dx
      scrollViewLeadingConstraint.constant += dx
      scrollViewTrailingConstraint.constant -= dx
    }
  }

  // ==================================================
  // NOTIFICATIONS
  // ==================================================

  override func setupNotifcations() {
    super.setupNotifcations()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
  }

  func orientationChanged(notification: NSNotification) {
    switch UIDevice.currentDevice().orientation {
    case .Portrait:
      Global.mode = .Light
      break
    case .PortraitUpsideDown:
      Global.mode = .Dark
      break
    default:
      break
    }
  }

}