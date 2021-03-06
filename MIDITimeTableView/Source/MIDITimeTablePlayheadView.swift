//
//  MIDITimeTablePlayheadView.swift
//  MIDITimeTableView
//
//  Created by Cem Olcay on 23.11.2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

/// Delegate that informs about playhead is going to move.
public protocol MIDITimeTablePlayheadViewDelegate: class {
  /// Delegate method that should update playhead's position based on pan gesture translation in timetable view.
  ///
  /// - Parameters:
  ///   - playheadView: Playhead that panning.
  ///   - panGestureRecognizer: Pan gesture that pans playhead.
  func playheadView(_ playheadView: MIDITimeTablePlayheadView, didPan panGestureRecognizer: UIPanGestureRecognizer)
}

/// Draws a triangle, movable playhead that customisable with a custom shape layer or an image.
public class MIDITimeTablePlayheadView: UIView {
  /// Current position on timetable. Based on beats.
  @objc public dynamic var position: Double = 0.0 { didSet{ updatePosition() }}
  /// MIDITimeTableMeasureView's width that used in layout playhead in timetable.
  public var measureBeatWidth: CGFloat = 0.0 { didSet{ updatePosition() }}
  /// MIDITimeTableMeasureView's height that used in layout playhead in timetable.
  public var measureHeight: CGFloat = 0.0 { didSet{ updatePosition() }}
  /// MIDITimeTableHeaderCellView's width that used in layout playhead in timetable.
  public var rowHeaderWidth: CGFloat = 0.0 { didSet{ updatePosition() }}

  /// Optional image for playhead instead of default triangle shape layer.
  public var image: UIImage? { didSet{ updateImage() }}
  /// Shape layer that draws triangle playhead shape. You can change the default shape.
  public var shapeLayer = CAShapeLayer() { didSet{ setNeedsLayout() } }

  /// Playhead's guide line color that draws on timetable.
  public var lineColor: UIColor = .white { didSet{ setNeedsLayout() }}
  /// Playhead's guide line height that draws on timetable. It's best to match timetable's content height.
  public var lineHeight: CGFloat = 0 { didSet{ setNeedsLayout() }}
  /// Playhead's guide line width that draws on timetable.
  public var lineWidth: CGFloat = 1 / UIScreen.main.scale { didSet{ setNeedsLayout() }}
  /// Line layer that draws playhead's position guide on timetable.
  private var lineLayer = CALayer()
  /// Optional image view that initilizes if an image assings.
  private var imageView: UIImageView?
  /// Delegate of playhead.
  public weak var delegate: MIDITimeTablePlayheadViewDelegate?

  // MARK: Init

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  public convenience init() {
    self.init(frame: .zero)
  }

  private func commonInit() {
    addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(pan:))))
    layer.addSublayer(lineLayer)
    layer.addSublayer(shapeLayer)
  }

  // Lifecycle

  public override func layoutSubviews() {
    super.layoutSubviews()
    lineLayer.frame.size = CGSize(width: lineWidth, height: lineHeight + (frame.height / 2))
    lineLayer.frame.origin.y = frame.height - (frame.height / 2)
    lineLayer.position.x = frame.width / 2
    lineLayer.backgroundColor = lineColor.cgColor
    imageView?.frame = CGRect(origin: .zero, size: frame.size)
    shapeLayer.frame = CGRect(origin: .zero, size: frame.size)
    drawShapeLayer()
  }

  private func updatePosition() {
    frame = CGRect(
      x: rowHeaderWidth + (CGFloat(position) * measureBeatWidth) - (frame.size.width / 2),
      y: 1,
      width: measureHeight,
      height: measureHeight - 1)
  }

  private func updateImage() {
    if let image = image {
      let imageView = UIImageView(image: image)
      addSubview(imageView)
      self.imageView = imageView
    } else {
      imageView?.removeFromSuperview()
      imageView = nil
    }
  }

  private func drawShapeLayer() {
    let width = frame.size.width
    let height = frame.size.height / 2
    let cornerRadius: CGFloat = 3
    let x = (frame.size.width - width) / 2
    let rectPath = UIBezierPath(
      roundedRect: CGRect(x: x, y: 0, width: width, height: height),
      byRoundingCorners: [.topLeft, .topRight],
      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    let trianglePath = UIBezierPath()
    trianglePath.move(to: CGPoint(x: rectPath.bounds.minX + 0.5, y: rectPath.bounds.maxY))
    trianglePath.addLine(to: CGPoint(x: (frame.size.width/2) - (lineWidth / 2), y: rectPath.bounds.maxY + height))
    trianglePath.addLine(to: CGPoint(x: (frame.size.width/2) + lineWidth, y: rectPath.bounds.maxY + height))
    trianglePath.addLine(to: CGPoint(x: rectPath.bounds.maxX - 0.5, y: rectPath.bounds.maxY))
    trianglePath.close()
    rectPath.append(trianglePath)

    shapeLayer.path = rectPath.cgPath
    shapeLayer.fillColor = tintColor.cgColor

    shapeLayer.shadowPath = rectPath.cgPath
    shapeLayer.shadowColor = UIColor.black.cgColor
    shapeLayer.shadowRadius = 1
  }

  @objc internal func didPan(pan: UIPanGestureRecognizer) {
    delegate?.playheadView(self, didPan: pan)
  }
}
