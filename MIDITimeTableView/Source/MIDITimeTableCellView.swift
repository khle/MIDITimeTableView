//
//  MIDITimeTableCellView.swift
//  MIDITimeTableView
//
//  Created by Cem Olcay on 16.10.2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit
import ALKit

/// Delegate functions to inform about editing or deleting cell.
public protocol MIDITimeTableCellViewDelegate: class {
  /// Informs about moving the cell with the pan gesture.
  ///
  /// - Parameters:
  ///   - midiTimeTableCellView: Cell that moving around.
  ///   - pan: Pan gesture that moves the cell.
  func midiTimeTableCellViewDidMove(_ midiTimeTableCellView: MIDITimeTableCellView, pan: UIPanGestureRecognizer)

  /// Informs about resizing the cell with the pan gesture.
  ///
  /// - Parameters:
  ///   - midiTimeTableCellView: Cell that resizing.
  ///   - pan: Pan gesture that resizes the cell.
  func midiTimeTableCellViewDidResize(_ midiTimeTableCellView: MIDITimeTableCellView, pan: UIPanGestureRecognizer)

  /// Informs about the cell is about to delete.
  ///
  /// - Parameter midiTimeTableCellView: Cell is going to delete.
  func midiTimeTableCellViewDidDelete(_ midiTimeTableCellView: MIDITimeTableCellView)
}

/// Defines a custom menu item for the `MIDITimeTableCellView` to show when you long press it.
public struct MIDITimeTableCellViewCustomMenuItem {
  /// Title of the custom menu item.
  public private(set) var title: String
  /// Action handler of the custom menu item.
  public private(set) var action: Selector

  /// Creates and returns a `UIMenuItem` from itself.
  public var menuItem: UIMenuItem {
    return UIMenuItem(title: title, action: action)
  }

  /// Initilizes custom `UIMenuItem` for `MIDITimeTableCellView`.
  ///
  /// - Parameters:
  ///   - title: Title of the custom menu item.
  ///   - action: Action handler of the custom menu item.
  public init(title: String, action: Selector) {
    self.title = title
    self.action = action
  }
}

/// Base cell view that shows on `MIDITimeTableView`. Has abilitiy to move, resize and delete.
open class MIDITimeTableCellView: UIView {
  /// View that holds the pan gesture on right most side in the view to use in resizing cell.
  private let resizeView = UIView()
  /// Inset from the rightmost side on the cell to capture resize gesture.
  public var resizePanThreshold: CGFloat = 10
  /// Delegate that informs about editing cell.
  public weak var delegate: MIDITimeTableCellViewDelegate?
  /// Custom items other than delete, when you long press cell.
  public var customMenuItems = [MIDITimeTableCellViewCustomMenuItem]()

  open override var canBecomeFirstResponder: Bool {
    return true
  }

  // MARK: Init

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    addSubview(resizeView)
    let resizeGesture = UIPanGestureRecognizer(target: self, action: #selector(didResize(pan:)))
    resizeView.addGestureRecognizer(resizeGesture)

    let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(didMove(pan:)))
    addGestureRecognizer(moveGesture)

    let longPressGesure = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(longPress:)))
    addGestureRecognizer(longPressGesure)
  }

  // MARK: Layout

  open override func layoutSubviews() {
    super.layoutSubviews()
    resizeView.frame = CGRect(
      x: frame.size.width - resizePanThreshold,
      y: 0,
      width: resizePanThreshold,
      height: frame.size.height)
  }

  // MARK: Gestures

  @objc public func didMove(pan: UIPanGestureRecognizer) {
    delegate?.midiTimeTableCellViewDidMove(self, pan: pan)
  }

  @objc public func didResize(pan: UIPanGestureRecognizer) {
    delegate?.midiTimeTableCellViewDidResize(self, pan: pan)
  }

  @objc public func didLongPress(longPress: UILongPressGestureRecognizer) {
    guard let superview = superview else { return }
    becomeFirstResponder()

    let menu = UIMenuController.shared
    menu.menuItems = [
      UIMenuItem(
        title: NSLocalizedString("Delete", comment: "Delete button"),
        action: #selector(didPressDeleteButton))
    ] + customMenuItems.map({ $0.menuItem })
    menu.arrowDirection = .up
    menu.setTargetRect(frame, in: superview)
    menu.setMenuVisible(true, animated: true)
  }

  @objc public func didPressDeleteButton() {
    delegate?.midiTimeTableCellViewDidDelete(self)
  }
}
