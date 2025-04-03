// Copyright © 2022 Olo Inc. All rights reserved.
// This software is made available under the Olo Pay SDK License (See LICENSE.md file)
//
//  OPApplePayButton.swift
//  OloPaySDK
//
//  Created by Justin Anderson on 3/18/25.
//

import UIKit
import PassKit

/// Convenience control that wraps Apple's `PKPaymentButton`
///
/// It is possible to use Apple's `PKPaymentButton` instead of this class if desired. This control provides all styling and customization options provided by
/// `PKPaymentButton` but also adds some extra functionality:
/// - Optional use of `onClick` property for simpler handling of touch events (`UIControl.addTarget(...)` is also supported)
/// - Ability to update button visuals after view creation (see `updateButton`)
///
///  - Important: The default height of this view matches the intrinsic  height of `PKPaymentButton`. If constraints or other factors cause this view's height
///    to expand beyond the intrinsic size, the `PKPaymentButton` will be centered vertically within this view.
@objc public class OPApplePayButton: UIControl {
    private static let defaultStyle = PKPaymentButtonStyle.black
    private static let defaultType = PKPaymentButtonType.checkout
    private static let defaultCornerRadius = CGFloat(8)
    
    private var _pkButton: PKPaymentButton!
    
    /// Initializes this control with default values of `PKPaymentButtonStyle.black`, `PKPaymentButtonType.checkout` and a corner radius of 8
    @objc public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    /// Initializes this control with default values of `PKPaymentButtonStyle.black`, `PKPaymentButtonType.checkout` and a corner radius of 8
    ///  - Parameters:
    ///     - frame: The frame to use for this control
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        _pkButton = makePaymentButton(
            type: OPApplePayButton.defaultType,
            style: OPApplePayButton.defaultStyle,
            cornerRadius: OPApplePayButton.defaultCornerRadius
        )
        
        setupViews()
    }
    
    /// Inititalizes this control with the given type, style, and corner radius
    /// - Parameters:
    ///    - type: The type of button to display
    ///    - style: The style to use for the button
    ///    - cornerRadius: The corner radius of the button
    @objc public convenience init(
        type: PKPaymentButtonType,
        style: PKPaymentButtonStyle,
        cornerRadius: CGFloat
    ) {
        self.init(frame: CGRect.zero, type: type, style: style, cornerRadius: cornerRadius)
    }
    
    /// Inititalizes this control with the given frame, type, style, and corner radius
    /// - Parameters:
    ///   - frame: The frame to use for this control
    ///   - type: The type of button to display
    ///   - style: The style to use for the button
    ///   - cornerRadius: The corner radius of the button
    @objc public init(
        frame: CGRect,
        type: PKPaymentButtonType,
        style: PKPaymentButtonStyle,
        cornerRadius: CGFloat
    ) {
        super.init(frame: frame)
        _pkButton = makePaymentButton(type: type, style: style, cornerRadius: cornerRadius)
        setupViews()
    }
    
    /// :nodoc:
    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
        _pkButton = makePaymentButton()
        setupViews()
    }
    
    /// Click handler to handle click events. It is also possible to handle click events using `UIControl.addTarget(...)`
    @objc public var onClick: (() -> Void)?
    
    /// Whether or not the button is enabled
    public override var isEnabled: Bool {
        didSet { _pkButton.isEnabled = isEnabled }
    }
    
    /// Whether or not user events are enabled or ignored and removed from the event queue
    public override var isUserInteractionEnabled: Bool {
        didSet { _pkButton.isUserInteractionEnabled = isUserInteractionEnabled }
    }
    
    /// Whether or not the button is highlighted
    public override var isHighlighted: Bool {
        didSet { _pkButton.isHighlighted = isHighlighted }
    }
    
    /// Updates the button with the given type, style, and corner radius
    ///  - Important: Because Apple does not provide a way to update the button type or style after creation, this method removes the current
    ///    `PKPaymentButton` instance from this view and then creates and attaches a new instance. If only the corner radius needs to be udpated
    ///    use `updateCornerRadius(...)` because that does not require the underlying button to be recreated.
    ///  - Parameters:
    ///   - type: The type of button to display
    ///   - style: The style to use for the button
    ///   - cornerRadius: The corner radius of the button
    @objc public func updateButton(
        type: PKPaymentButtonType,
        style: PKPaymentButtonStyle,
        cornerRadius: CGFloat
    ) {
        // Out with the old...
        _pkButton.removeFromSuperview()
        
        // ...and in with the new
        _pkButton = makePaymentButton(type: type, style: style, cornerRadius: cornerRadius)
        setupViews()
    }
    
    /// Updates the corner radius of the button
    /// - Parameters:
    ///  - cornerRadius: The corner radius for the button
    @objc public func updateCornerRadius(cornerRadius: CGFloat) {
        _pkButton.cornerRadius = cornerRadius
    }
    
    /// :nodoc:
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pointInButton = _pkButton.convert(point, from: self)
        if _pkButton.bounds.contains(pointInButton) && _pkButton.isEnabled {
            return _pkButton
        }
        
        //Ignore taps outside the bounds of the pkButton
        return nil
    }
    
    private func setupViews() {
        // Sync wrapper state with button state
        _pkButton.isEnabled = isEnabled
        _pkButton.isHighlighted = isHighlighted
        _pkButton.isUserInteractionEnabled = isUserInteractionEnabled
        
        _pkButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(_pkButton)
               
        let intrinsicHeight = _pkButton.intrinsicContentSize.height
        
        let constraints = [
            _pkButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            _pkButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            _pkButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            _pkButton.heightAnchor.constraint(equalToConstant: intrinsicHeight),
            
            _pkButton.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 0),
            _pkButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 0),
        ]

        NSLayoutConstraint.activate(constraints)
        
        let defaultHeight = heightAnchor.constraint(equalTo: _pkButton.heightAnchor)
        defaultHeight.priority = .defaultLow
        defaultHeight.isActive = true
    }
    
    private func makePaymentButton(
        type: PKPaymentButtonType = defaultType,
        style: PKPaymentButtonStyle = defaultStyle,
        cornerRadius: CGFloat = defaultCornerRadius
    ) -> PKPaymentButton {
        let button = PKPaymentButton(
            paymentButtonType: type,
            paymentButtonStyle: style
        )
        
        button.cornerRadius = cornerRadius
        button.addTarget(self, action: #selector(onButtonClicked), for: .touchUpInside)
        
        return button
    }
    
    @objc private func onButtonClicked() {
        onClick?()
        sendActions(for: .touchUpInside)
    }
}
