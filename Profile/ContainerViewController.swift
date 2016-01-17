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

  @IBOutlet weak var bottomGradientView: LinearGradientView!
  @IBOutlet weak var contactView: UIView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var indexView: UIView!
  @IBOutlet weak var topGradientView: LinearGradientView!
  @IBOutlet weak var scrollView: UIScrollView!

  @IBOutlet weak var contactViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var indexViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var scrollViewTrailingConstraint: NSLayoutConstraint!

  let SideMenuOffset: CGFloat = 10

  var currentDirection: UIPanGestureRecognizerDirection = .None
  var currentIndex = 0
  var currentStage = 0
  var homeIndex = 0

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

    contactViewTrailingConstraint.constant = Global.isContactOpen ? 0 : -contactView.frame.width
    indexViewLeadingConstraint.constant = Global.isIndexOpen ? 0 : -indexView.frame.width

    setupData()
    setupInitialViewControllers()
    setupGestures()
    setupNotifcations()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    snapContent(false)
    NSNotificationCenter.defaultCenter().postNotificationName(
      Global.ScrollEndedNotification,
      object: nil,
      userInfo: [
        "dy": CGFloat(0),
        "panDy": CGFloat(0),
        "dyThreshold": false,
        "currentDirection": currentDirection.rawValue,
        "currentIndex": currentIndex,
        "currentStage": currentStage
      ]
    )
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

    homeIndex = dataArray.count
    currentIndex = homeIndex
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
    for (i, item) in items.enumerate() {
      if item["title"] != "Home" {
        let itemViewController = i < homeIndex ? UIStoryboard.workItemViewController() : UIStoryboard.teamItemViewController()
        contentView.addSubview(itemViewController.view)
        addChildViewController(itemViewController)
        itemViewController.didMoveToParentViewController(self)
        itemViewController.data = item
        itemViewController.index = i
        itemViewControllers.append(itemViewController)
      } else {
        let itemViewController = UIStoryboard.homeViewController()
        contentView.addSubview(itemViewController.view)
        addChildViewController(itemViewController)
        itemViewController.didMoveToParentViewController(self)
        itemViewController.index = homeIndex
        itemViewControllers.append(itemViewController)
      }
    }
  }

  override func updateColors() {
    view.backgroundColor = UIColor.appPrimaryBackgroundColor()
    bottomGradientView.fromColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(0)
    bottomGradientView.toColor = UIColor.appPrimaryBackgroundColor()
    topGradientView.fromColor = UIColor.appPrimaryBackgroundColor()
    topGradientView.toColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(0)
  }

  // ==================================================
  // CONTACT / INDEX
  // ==================================================

  func snapContent(animated: Bool) {
    let duration = animated ? 0.3 : 0
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.scrollView.setContentOffset(CGPoint(x: 0, y: self.view.frame.height * CGFloat(self.currentIndex)), animated: false)
    }, completion: nil)

    UIView.animateWithDuration(duration) { () -> Void in
      self.topGradientView.alpha = self.currentIndex < self.homeIndex && (self.currentIndex > 0 || self.currentIndex == 0 && self.currentStage == 0) ? 1 : 0
      self.bottomGradientView.alpha = self.currentIndex > self.homeIndex && (self.currentIndex < self.items.count-1 || self.currentIndex == self.items.count-1 && self.currentStage == 0) ? 1 : 0
    }
  }

  func openCloseContact(open: Bool, animated: Bool) {
    let duration = animated ? 0.3 : 0
    Global.isContactOpen = open
    view.layoutIfNeeded()
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.contactViewTrailingConstraint.constant = open ? -self.SideMenuOffset : -self.contactView.frame.width
      self.scrollViewLeadingConstraint.constant = open ? -self.contactView.frame.width + self.SideMenuOffset : 0
      self.scrollViewTrailingConstraint.constant = open ? self.contactView.frame.width - self.SideMenuOffset : 0
      self.view.layoutIfNeeded()
    }, completion: nil)
  }

  func openCloseIndex(open: Bool, animated: Bool) {
    let duration = animated ? 0.3 : 0
    Global.isIndexOpen = open
    view.layoutIfNeeded()
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.indexViewLeadingConstraint.constant = open ? -self.SideMenuOffset : -self.indexView.frame.width
      self.scrollViewLeadingConstraint.constant = open ? self.indexView.frame.width - self.SideMenuOffset : 0
      self.scrollViewTrailingConstraint.constant = open ? -self.indexView.frame.width + self.SideMenuOffset : 0
      self.view.layoutIfNeeded()
    }, completion: nil)
  }

  // ==================================================
  // GESTURES
  // ==================================================

  func setupGestures() {
    let panGesture = UIPanGestureRecognizer(target: self, action: "panned:")
    view.addGestureRecognizer(panGesture)
  }

  func panned(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translationInView(view)
    let dx = translation.x
    let dy = translation.y
    let direction: UIPanGestureRecognizerDirection = gesture.direction(view)
    gesture.setTranslation(CGPointZero, inView: view)

    switch gesture.state {
    case .Began:
      panDx = 0
      panDy = 0
      currentDirection = direction

      switch direction {
      case .Left:
        if Global.isIndexOpen {
          isPanningIndex = true
        } else {
          isPanningContact = true
        }
        break
      case .Right:
        if Global.isContactOpen {
          isPanningContact = true
        } else {
          isPanningIndex = true
        }
        break
      case .Up:
        isPanningContent = !Global.isIndexOpen && !Global.isContactOpen
        break
      case .Down:
        isPanningContent = !Global.isIndexOpen && !Global.isContactOpen
        break
      default:
        break
      }

      break

    case .Changed:
      panDx += dx
      panDy += dy

      if isPanningContent {
        panContentView(dy)
        NSNotificationCenter.defaultCenter().postNotificationName(
          Global.ScrollChangedNotification,
          object: nil,
          userInfo: [
            "dy": dy,
            "panDy": panDy,
            "currentDirection": currentDirection.rawValue,
            "currentIndex": currentIndex,
            "currentStage": currentStage
          ]
        )
      } else if isPanningContact {
        panContactView(dx)
      } else if isPanningIndex {
        panIndexView(dx)
      }

      break

    case .Ended:
      let dxThreshold = abs(panDx) >= view.frame.width / 3
      let dyThreshold = abs(panDy) >= view.frame.height / 3

      if isPanningContent {
        if dyThreshold {
          if currentDirection == .Up {
            if currentIndex == homeIndex ||
              (currentIndex < homeIndex && currentStage == 0) ||
              (currentIndex > homeIndex && currentStage == 1) {
                let nextIndex = currentIndex + 1
                if nextIndex >= items.count {
                  currentIndex = items.count - 1
                  currentStage = 1
                } else {
                  currentIndex = nextIndex
                  currentStage = currentIndex < homeIndex ? 1 : 0
                }
            } else if currentIndex != homeIndex {
              if currentIndex < homeIndex && currentStage == 1 {
                currentStage = 0
              } else if currentIndex > homeIndex && currentStage == 0 {
                currentStage = 1
              }
            }
          } else if currentDirection == .Down {
            if currentIndex == homeIndex ||
              (currentIndex < homeIndex && currentStage == 1) ||
              (currentIndex > homeIndex && currentStage == 0) {
                let previousIndex = currentIndex - 1
                if previousIndex <= 0 {
                  currentIndex = 0
                  currentStage = 1
                } else {
                  currentIndex = previousIndex
                  currentStage = currentIndex <= homeIndex ? 0 : 1
                }
            } else if currentIndex != homeIndex {
              if currentIndex < homeIndex && currentStage == 0 {
                currentStage = 1
              } else if currentIndex > homeIndex && currentStage == 1 {
                currentStage = 0
              }
            }
          }
        }
        snapContent(true)
        NSNotificationCenter.defaultCenter().postNotificationName(
          Global.ScrollEndedNotification,
          object: nil,
          userInfo: [
            "dy": dy,
            "panDy": panDy,
            "dyThreshold": dyThreshold,
            "currentDirection": currentDirection.rawValue,
            "currentIndex": currentIndex,
            "currentStage": currentStage
          ]
        )
        print("currentDirection: \(currentDirection)", "currentIndex: \(currentIndex)", "currentStage: \(currentStage)")
      } else if isPanningContact {
        let open = dxThreshold ? !Global.isContactOpen : Global.isContactOpen
        openCloseContact(open, animated: true)
      } else if isPanningIndex {
        let open = dxThreshold ? !Global.isIndexOpen : Global.isIndexOpen
        openCloseIndex(open, animated: true)
      }

      isPanningContent = false
      isPanningContact = false
      isPanningIndex = false
      currentDirection = .None

      break

    default:
      break
    }
  }

  func panContentView(dy: CGFloat) {
    if currentIndex == homeIndex ||
      (currentIndex < homeIndex && currentStage == 0 && currentDirection == .Up) ||
      (currentIndex < homeIndex && currentStage == 1 && currentDirection == .Down) ||
      (currentIndex > homeIndex && currentStage == 0 && currentDirection == .Down) ||
      (currentIndex > homeIndex && currentStage == 1 && currentDirection == .Up) {
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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeContact:", name: Global.CloseContactNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeIndex:", name: Global.CloseIndexNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "openContact:", name: Global.OpenContactNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "openIndex:", name: Global.OpenIndexNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
  }

  func closeContact(notification: NSNotification) {
    openCloseContact(false, animated: true)
  }

  func closeIndex(notification: NSNotification) {
    openCloseIndex(false, animated: true)
  }

  func openContact(notification: NSNotification) {
    openCloseContact(true, animated: true)
  }

  func openIndex(notification: NSNotification) {
    openCloseIndex(true, animated: true)
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
