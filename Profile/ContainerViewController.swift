//
//  ContainerViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import SwiftyJSON
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

  var items: [JSON] = [
    ["title": "Home"]
  ]
  var itemViewControllers = [UIViewController]()
  var continueArrowViews = [String: ContinueArrowView]()

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

  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return .All
  }

  override func shouldAutorotate() -> Bool {
    return UIDevice.currentDevice().orientation == .Portrait ||
           UIDevice.currentDevice().orientation == .PortraitUpsideDown
  }

  override func updateColors() {
    view.backgroundColor = UIColor.appPrimaryBackgroundColor()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ContainerToIndex" {
      let vc = segue.destinationViewController as! IndexViewController
      vc.delegate = self
    }
  }

  func setupData() {
    setupWorkData()
    setupTeamData()
    NSNotificationCenter.defaultCenter().postNotificationName(Global.DataLoaded, object: nil)
  }

  func setupWorkData() {
    guard let path = NSBundle.mainBundle().pathForResource("WorkData", ofType: "plist") else { return }
    guard let dataArray = NSArray(contentsOfFile: path) else { return }

    for data in dataArray {
      items.insert(JSON(data), atIndex: 0)
    }

    homeIndex = dataArray.count
    currentIndex = homeIndex
  }

  func setupTeamData() {
    guard let path = NSBundle.mainBundle().pathForResource("TeamData", ofType: "plist") else { return }
    guard let dataArray = NSArray(contentsOfFile: path) else { return }

    for data in dataArray {
      items.append(JSON(data))
    }
  }

  func setupInitialViewControllers() {
    for (i, item) in items.enumerate() {
      if item["title"].stringValue != "Home" {
        let itemViewController = i < homeIndex ? UIStoryboard.workItemViewController() : UIStoryboard.teamItemViewController()
        itemViewController.delegate = self
        itemViewController.index = i
        contentView.addSubview(itemViewController.view)
        addChildViewController(itemViewController)
        itemViewController.didMoveToParentViewController(self)
        itemViewController.data = item
        itemViewControllers.append(itemViewController)

        itemViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "H:|[subview(width)]",
          options: [],
          metrics: ["width": view.frame.width],
          views: ["subview": itemViewController.view])
        )
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "V:|-padding-[subview(height)]",
          options: [],
          metrics: ["height": view.frame.height, "padding": view.frame.height * CGFloat(itemViewController.index)],
          views: ["subview": itemViewController.view])
        )
      } else {
        let itemViewController = UIStoryboard.homeViewController()
        itemViewController.index = homeIndex
        contentView.addSubview(itemViewController.view)
        addChildViewController(itemViewController)
        itemViewController.didMoveToParentViewController(self)
        itemViewControllers.append(itemViewController)

        itemViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "H:|[subview(width)]",
          options: [],
          metrics: ["width": view.frame.width],
          views: ["subview": itemViewController.view])
        )
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "V:|-padding-[subview(height)]",
          options: [],
          metrics: ["height": view.frame.height, "padding": view.frame.height * CGFloat(itemViewController.index)],
          views: ["subview": itemViewController.view])
        )
      }
    }

    contentView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview(height)]", options: [], metrics: ["height": view.frame.height * CGFloat(items.count)], views: ["subview": contentView]))

    // Setup arrow contraints
    let arrowWidth: CGFloat = 40
    let arrowHeight: CGFloat = 55
    let arrowOffset: CGFloat = 25
    let arrowMargin: CGFloat = 17
    for i in 0..<items.count {
      if i == homeIndex { continue }
      let stage0ContinueArrowView = NSBundle.mainBundle().loadNibNamed("ContinueArrowView", owner: self, options: nil).last as! ContinueArrowView
      stage0ContinueArrowView.translatesAutoresizingMaskIntoConstraints = false
//      stage0ContinueArrowView.backgroundColor = UIColor.redColor()
      continueArrowViews["itemViewStage0-\(i)"] = stage0ContinueArrowView

      let stage1ContinueArrowView = NSBundle.mainBundle().loadNibNamed("ContinueArrowView", owner: self, options: nil).last as! ContinueArrowView
      stage1ContinueArrowView.translatesAutoresizingMaskIntoConstraints = false
//      stage1ContinueArrowView.backgroundColor = UIColor.greenColor()
      continueArrowViews["itemViewStage1-\(i)"] = stage1ContinueArrowView

      if (i < homeIndex) {
        stage0ContinueArrowView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        stage1ContinueArrowView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
      }

      contentView.addSubview(stage0ContinueArrowView)
      contentView.addSubview(stage1ContinueArrowView)

      if i < homeIndex {
        // Work Stage 0 Arrow
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "H:[subview(width)]-padding-|",
          options: [],
          metrics: [
            "width": arrowWidth,
            "padding": arrowMargin
          ],
          views: ["subview": stage0ContinueArrowView])
        )
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "V:|-padding-[subview(height)]",
          options: [],
          metrics: [
            "height": arrowHeight,
            "padding": view.frame.height * CGFloat(i + 1) - arrowOffset
          ],
          views: ["subview": stage0ContinueArrowView])
        )

        // Work Stage 1 Arrow
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "H:|-padding-[subview(width)]",
          options: [],
          metrics: [
            "width": arrowWidth,
            "padding": arrowMargin
          ],
          views: ["subview": stage1ContinueArrowView])
        )
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "V:|-padding-[subview(height)]",
          options: [],
          metrics: [
            "height": arrowHeight,
            "padding": view.frame.height * CGFloat(i) - arrowOffset
          ],
          views: ["subview": stage1ContinueArrowView])
        )
      } else {
        // Team Stage 0 Arrow
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "H:|-padding-[subview(width)]",
          options: [],
          metrics: [
            "width": arrowWidth,
            "padding": arrowMargin
          ],
          views: ["subview": stage0ContinueArrowView])
        )
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "V:|-padding-[subview(height)]",
          options: [],
          metrics: [
            "height": arrowHeight,
            "padding": view.frame.height * CGFloat(i) - arrowOffset
          ],
          views: ["subview": stage0ContinueArrowView])
        )

        // Team Stage 1 Arrow
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "H:[subview(width)]-padding-|",
          options: [],
          metrics: [
            "width": arrowWidth,
            "padding": arrowMargin
          ],
          views: ["subview": stage1ContinueArrowView])
        )
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
          "V:|-padding-[subview(height)]",
          options: [],
          metrics: [
            "height": arrowHeight,
            "padding": view.frame.height * CGFloat(i + 1) - arrowOffset
          ],
          views: ["subview": stage1ContinueArrowView])
        )
      }
    }
  }

  // ==================================================
  // CONTACT / INDEX
  // ==================================================

  func snapContent(animated: Bool) {
    let duration = animated ? 0.3 : 0
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.scrollView.setContentOffset(CGPoint(x: 0, y: self.view.frame.height * CGFloat(self.currentIndex)), animated: false)
    }, completion: nil)
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

  func openCloseIndex(open: Bool, animated: Bool, completion: (() -> Void)? = nil) {
    let duration = animated ? 0.3 : 0
    Global.isIndexOpen = open
    view.layoutIfNeeded()
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
      self.indexViewLeadingConstraint.constant = open ? -self.SideMenuOffset : -self.indexView.frame.width
      self.scrollViewLeadingConstraint.constant = open ? self.indexView.frame.width - self.SideMenuOffset : 0
      self.scrollViewTrailingConstraint.constant = open ? -self.indexView.frame.width + self.SideMenuOffset : 0
      self.view.layoutIfNeeded()
    }, completion: { (completed) -> Void in
      completion?()
    })
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
          if currentIndex == homeIndex {
            if currentDirection == .Up {
              let nextIndex = currentIndex + 1
              currentIndex = nextIndex >= items.count ? items.count - 1 : nextIndex
            } else if currentDirection == .Down {
              let previousIndex = currentIndex - 1
              currentIndex = previousIndex <= 0 ? 0 : previousIndex
            }
            currentStage = 0
          } else if currentIndex < homeIndex {
            if currentDirection == .Up {
              if currentStage == 0 {
                currentIndex++
                currentStage = currentIndex == homeIndex ? 0 : 1
              } else {
                currentStage--
              }
            } else if currentDirection == .Down {
              if currentStage == 0 {
                currentStage++
              } else {
                let previousIndex = currentIndex - 1
                if previousIndex < 0 {
                  currentIndex = 0
                  currentStage = 1
                } else {
                  currentIndex = previousIndex
                  currentStage = 0
                }
              }
            }
          } else {
            if currentDirection == .Up {
              if currentStage == 0 {
                currentStage++
              } else {
                let nextIndex = currentIndex + 1
                if nextIndex >= items.count {
                  currentIndex = items.count - 1
                  currentStage = 1
                } else {
                  currentIndex = nextIndex
                  currentStage = 0
                }
              }
            } else if currentDirection == .Down {
              if currentStage == 0 {
                currentIndex--
                currentStage = currentIndex == homeIndex ? 0 : 1
              } else {
                currentStage--
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
