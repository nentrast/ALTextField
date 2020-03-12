//
//  ALTextField.swift
//  ALTextField
//
//  Created by Alexandr Lobanov on 12.03.2020.
//  Copyright © 2020 Alexandr Lobanov. All rights reserved.
//

import UIKit
import Validator

@IBDesignable
class ALTextField: UITextField {
    
    // MARK: - Initializer
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Overriding
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect)
        setup()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: horizontalTextMargin,
                      y: 0,
                      width: bounds.size.width - horizontalTextMargin * 2,
                      height: bounds.size.height - self.errorHeight())
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.textRect(forBounds: bounds)
    }
    
    // MARK: - Views
    
    open var errorLabel: UILabel!
    private let bgView = UIView()

    // MARK: - Colors
    
    open var errorLabelColor: UIColor = .red
    open var borderColorActive: UIColor? = .gray
    open var borderColorInactive: UIColor? = .gray
    open var borderColorError: UIColor = .red
    open var backgroundActive: UIColor = .clear
    open var backgroundInactive: UIColor = .clear
    
    open var placeholderColor: UIColor {
        get {
            guard let currentAttributedPlaceholderColor = attributedPlaceholder?.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as? UIColor else {
               
                return UIColor.clear
            }
            return currentAttributedPlaceholderColor
        }
        set {
            guard let currentAttributedString = attributedPlaceholder else {
                return
            }
            let attributes = [NSAttributedString.Key.foregroundColor : newValue]
            
            attributedPlaceholder = NSAttributedString(string: currentAttributedString.string, attributes: attributes)
        }
    }
    
    
    // MARK: -
    
    open var errorLabelFont: UIFont = UIFont.systemFont(ofSize: 12)
    
    open var error: String? {
        didSet {
            self.updateControl(true)
        }
    }
    
    open var borederWidth: CGFloat = 1
    open var corenrRadius: CGFloat = 8
    open var validationRule: AlValidationRuleType?
    
    // MARK: - Animation
    open var titleFadeInDuration: TimeInterval = 0.2
    open var titleFadeOutDuration: TimeInterval = 0.3

    
    var horizontalTextMargin: CGFloat = 16
    var cornerRadius: CGFloat = 8
    
    
    @IBInspectable var backgroundColorForInactiveState: UIColor? {
        didSet {
            backgroundColor = backgroundColorForInactiveState
        }
    }
    
    override var backgroundColor: UIColor? {
        set {
            bgView.backgroundColor = newValue
        }
        get {
            return bgView.backgroundColor
        }
    }
    
    // Calcualte the height of the textfield.
    open func textHeight() -> CGFloat {
      return (self.font?.lineHeight ?? 15.0) + 7.0
    }
    
    open func errorHeight() -> CGFloat {
      return self.errorLabelRectForBounds(self.bounds).size.height
    }
    
    // MARK: Responder handling
    
    // Attempt the control to become the first responder
    override open func becomeFirstResponder() -> Bool {
      let result = super.becomeFirstResponder()
      self.updateControl(true)
      return result
    }
    
    // Attempt the control to resign being the first responder
    override open func resignFirstResponder() -> Bool {
      let result =  super.resignFirstResponder()
      self.updateControl(true)
      return result
    }
    

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
      return textRect(forBounds: bounds)
    }
    
    override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
      var rect = textRect(forBounds: bounds)
      rect.size.width = 34
      rect.origin.x = bounds.size.width - rect.size.width
      return rect
    }
    
    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
      return rightViewRect(forBounds: bounds)
    }
    
    open func errorLabelRectForBounds(_ bounds: CGRect) -> CGRect {
       guard let error = error, !error.isEmpty else { return CGRect.zero }
       let font: UIFont = errorLabel.font ?? UIFont.systemFont(ofSize: 17.0)
       
       let textAttributes = [NSAttributedString.Key.font: font]
       let s = CGSize(width: bounds.size.width, height: 2000)
       let boundingRect = error.boundingRect(with: s, options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
       return CGRect(x: 0, y: bounds.size.height - boundingRect.size.height, width: boundingRect.size.width, height: boundingRect.size.height)
     }
    
    // Invoked when the interface builder renders the control
    override open func prepareForInterfaceBuilder() {
      if #available(iOS 8.0, *) {
        super.prepareForInterfaceBuilder()
      }
      self.isSelected = true
      self.updateControl(false)
      self.invalidateIntrinsicContentSize()
    }
    
    override open func layoutSubviews() {
      super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
        bgView.layer.cornerRadius = cornerRadius
        errorLabel.frame = errorLabelRectForBounds(bounds)
        
        // Fix unwanted rightView sliding in animation when it's first shown
        // https://stackoverflow.com/questions/18853972/how-to-stop-the-animation-of-uitextfield-rightview
        rightView?.frame = rightViewRect(forBounds: bounds)
    }
    
    override open var intrinsicContentSize: CGSize {
      let height = errorHeight()
      //print("height \(height)")
      return CGSize(width: bounds.size.width, height: height)
    }
    
    open override var description: String {
      return "[ALTextField(\(String(describing: placeholder))) text:\(String(describing: text))]"
    }
    
    // MARK: - view update
    
    fileprivate func updateControl(_ animated:Bool = false) {
       self.invalidateIntrinsicContentSize()
       self.updateColors()
       self.updateErrorLabel(animated)
     }
    
     fileprivate func updateErrorLabel(_ animated:Bool = false) {
       self.errorLabel.text = error
       self.invalidateIntrinsicContentSize()
     }
    

    fileprivate final func setup() {
        borderStyle = .none
        createErrorLabel()
        updateColors()
        configureBackgroundView()
    }
    
    // MARK: - private methods
    
    private  func updateColors() {
        backgroundColor = backgroundColorForInactiveState
    }
        
    private func createErrorLabel() {
      let label = UILabel()
      label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      label.font = errorLabelFont
      label.alpha = 1.0
      label.numberOfLines = 0
      label.textColor = errorLabelColor
      label.accessibilityIdentifier = "error-label"
      self.addSubview(label)
      self.errorLabel = label
    }
    
    private func configureBackgroundView(){
        bgView.frame = bounds
        bgView.layer.masksToBounds = true
        bgView.isUserInteractionEnabled = false
        bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(bgView, at: 0)
        bgView.backgroundColor = backgroundColorForInactiveState
    }
}
    
