//
//  ContainerViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

class ContainerViewController: PROViewController {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var contactView: UIView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var indexView: UIView!
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var loadingLogoImageView: UIImageView!
  @IBOutlet weak var loadingProgressView: UIView!
  @IBOutlet weak var scrollView: UIScrollView!

  @IBOutlet weak var contactViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var indexViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var loadingProgressWidthConstraint: NSLayoutConstraint!
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
  var isDataReady = false

  var panDx: CGFloat = 0
  var panDy: CGFloat = 0

  var items: [JSON] = [
    ["title": "Home"]
  ]
  var itemViewControllers = [UIViewController]()
  var continueArrowViews = [String: ContinueArrowView]()
  var continueArrowConstraints = [String: NSLayoutConstraint]()

  var loadingTimer: NSTimer?

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()

    contactViewTrailingConstraint.constant = Global.isContactOpen ? 0 : -contactView.frame.width
    indexViewLeadingConstraint.constant = Global.isIndexOpen ? 0 : -indexView.frame.width
    loadingProgressWidthConstraint.constant = 0
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if items.count == 1 {
      downloadData()
      startLoadingAnimation()
    }
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
    for (_, continueArrowView) in continueArrowViews {
      continueArrowView.arrowHeadImageView.tintColor = UIColor.appPrimaryTextColor()
      continueArrowView.arrowTailImageView.tintColor = UIColor.appPrimaryTextColor()
      continueArrowView.arrowStemImageView.dotColor = UIColor.appPrimaryTextColor()
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ContainerToIndex" {
      let vc = segue.destinationViewController as! IndexViewController
      vc.delegate = self
    }
  }

  func startLoadingAnimation() {
    invalidateLoadingTimer()
    loadingTimer = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "animateLoadingProgress", userInfo: nil, repeats: false)
  }

  func animateLoadingProgress() {
    loadingProgressWidthConstraint.constant = 0
    view.layoutIfNeeded()
    UIView.animateWithDuration(2, animations: { () -> Void in
      self.loadingProgressWidthConstraint.constant = self.loadingLogoImageView.frame.width
      self.view.layoutIfNeeded()
    }) { (completed) -> Void in
      if self.isDataReady {
        UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
          self.loadingView.alpha = 0
        }, completion: { (completed) -> Void in
          NSNotificationCenter.defaultCenter().postNotificationName(Global.AppBootedNotification, object: nil)
          self.loadingView.hidden = true
        })
      } else {
        self.startLoadingAnimation()
      }
    }
  }

  func invalidateLoadingTimer() {
    loadingTimer?.invalidate()
    loadingTimer = nil
  }

  func downloadData() {
    let env = NSProcessInfo.processInfo().environment
    let baseUrl = env["API_BASE_URL"] != nil ? env["API_BASE_URL"]! : "https://soap-profile.herokuapp.com"
    print("Using: \(baseUrl)")

    Alamofire.request(.GET, "\(baseUrl)/data.json").validate().responseJSON { [unowned self] response in
      switch response.result {
      case .Success:
        if let value = response.result.value {
          self.downloadDataSuccess(JSON(value))
        }
      case .Failure(let error):
        print(error)
        self.downloadDataError()
        self.invalidateLoadingTimer()
      }
    }
  }

  func downloadDataSuccess(data: JSON) {
    // Gather work items
    if let workData = data.dictionaryValue["work"] {
      for item in workData.arrayValue {
        if !items.contains(item) {
          items.insert(item, atIndex: 0)
        }
      }

      // Setup initial indexes
      homeIndex = workData.arrayValue.count
      currentIndex = homeIndex
    }

    // Gather team items
    if let teamData = data.dictionaryValue["team"] {
      for item in teamData.arrayValue {
        if !items.contains(item) {
          items.append(item)
        }
      }
    }

    setupInitialViewControllers()
    setupGestures()

    NSNotificationCenter.defaultCenter().postNotificationName(Global.DataLoaded, object: nil)

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

    updateColors()

    isDataReady = true
  }

  func downloadDataError() {
    let alertViewController = UIAlertController(title: "Oops!", message: "Something went wrong downloading data. Want to try again?", preferredStyle: .Alert)
    alertViewController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
    alertViewController.addAction(UIAlertAction(title: "Try Again", style: .Default, handler: { [unowned self] (alertAction) -> Void in
      self.downloadData()
      self.startLoadingAnimation()
    }))
    presentViewController(alertViewController, animated: true, completion: nil)
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
    let arrowHeight: CGFloat = 80
    let arrowMargin: CGFloat = 17
    for (i, viewController) in itemViewControllers.enumerate() {
      if i == homeIndex { continue }

      let arrowOffset: CGFloat = i < homeIndex ? Global.WorkArrowOffset : Global.TeamArrowOffset
      let itemViewController = viewController as! ItemViewController

      let stage0ContinueArrowView = NSBundle.mainBundle().loadNibNamed("ContinueArrowView", owner: self, options: nil).last as! ContinueArrowView
      stage0ContinueArrowView.translatesAutoresizingMaskIntoConstraints = false
      stage0ContinueArrowView.index = i
      stage0ContinueArrowView.stage = 0
      continueArrowViews["itemViewStage0-\(i)"] = stage0ContinueArrowView

      let stage1ContinueArrowView = NSBundle.mainBundle().loadNibNamed("ContinueArrowView", owner: self, options: nil).last as! ContinueArrowView
      stage1ContinueArrowView.index = i
      stage1ContinueArrowView.stage = 1
      stage1ContinueArrowView.translatesAutoresizingMaskIntoConstraints = false
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
          "V:[subview(height)]",
          options: [],
          metrics: [
            "height": arrowHeight
          ],
          views: ["subview": stage0ContinueArrowView])
        )
        let arrowStage0Constraint = NSLayoutConstraint(
          item: stage0ContinueArrowView,
          attribute: .Top,
          relatedBy: .Equal,
          toItem: itemViewController.itemView,
          attribute: .Bottom,
          multiplier: 1,
          constant: -arrowOffset
        )
        contentView.addConstraint(arrowStage0Constraint)
        continueArrowConstraints["itemView\(i)-stage0"] = arrowStage0Constraint

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
          "V:[subview(height)]",
          options: [],
          metrics: [
            "height": arrowHeight
          ],
          views: ["subview": stage1ContinueArrowView])
        )
        let arrowStage1Constraint = NSLayoutConstraint(
          item: stage1ContinueArrowView,
          attribute: .Top,
          relatedBy: .Equal,
          toItem: itemViewController.itemView.descriptionPositionView,
          attribute: .Bottom,
          multiplier: 1,
          constant: -arrowOffset
        )
        contentView.addConstraint(arrowStage1Constraint)
        continueArrowConstraints["itemView\(i)-stage1"] = arrowStage1Constraint
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
          "V:[subview(height)]",
          options: [],
          metrics: [
            "height": arrowHeight,
          ],
          views: ["subview": stage0ContinueArrowView])
        )
        let arrowStage0Constraint = NSLayoutConstraint(
          item: stage0ContinueArrowView,
          attribute: .Top,
          relatedBy: .Equal,
          toItem: itemViewController.itemView,
          attribute: .Top,
          multiplier: 1,
          constant: -arrowOffset
        )
        contentView.addConstraint(arrowStage0Constraint)
        continueArrowConstraints["itemView\(i)-stage0"] = arrowStage0Constraint

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
          "V:[subview(height)]",
          options: [],
          metrics: [
            "height": arrowHeight
          ],
          views: ["subview": stage1ContinueArrowView])
        )
        let arrowStage1Constraint = NSLayoutConstraint(
          item: stage1ContinueArrowView,
          attribute: .Top,
          relatedBy: .Equal,
          toItem: itemViewController.itemView.descriptionPositionView,
          attribute: .Top,
          multiplier: 1,
          constant: -arrowOffset
        )
        contentView.addConstraint(arrowStage1Constraint)
        continueArrowConstraints["itemView\(i)-stage1"] = arrowStage1Constraint
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
      let dxThreshold = abs(panDx) >= Global.SwipeThreshold
      let dyThreshold = abs(panDy) >= Global.SwipeThreshold

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
    NSNotificationCenter.defaultCenter().postNotificationName(Global.ContactPanningNotification, object: nil)
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
    NSNotificationCenter.defaultCenter().postNotificationName(Global.IndexPanningNotification, object: nil)
  }

  // ==================================================
  // NOTIFICATIONS
  // ==================================================

  override func setupNotifcations() {
    super.setupNotifcations()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "appBooted:", name: Global.AppBootedNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "arrowBottomTapped:", name: Global.ArrowBottomTappedNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "arrowTopTapped:", name: Global.ArrowTopTappedNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeContact:", name: Global.CloseContactNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeIndex:", name: Global.CloseIndexNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "openContact:", name: Global.OpenContactNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "openIndex:", name: Global.OpenIndexNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
  }

  func appBooted(notification: NSNotification) {
    Global.isAppBooted = true
  }

  func arrowBottomTapped(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let index = userInfo["index"] as! Int
    let stage = userInfo["stage"] as! Int

    if index < homeIndex {
      currentIndex = stage == 0 ? index + 1 : index
    } else {
      currentIndex = stage == 0 ? index - 1 : index
    }
    currentStage = stage == 0 ? 1 : 0
    snapContent(true)
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

  func arrowTopTapped(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let index = userInfo["index"] as! Int
    let stage = userInfo["stage"] as! Int

    currentIndex = index
    currentStage = stage
    snapContent(true)
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
