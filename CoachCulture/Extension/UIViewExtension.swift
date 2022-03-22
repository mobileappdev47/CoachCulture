
import UIKit.UIView

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    
    
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func applyBorder(_ width: CGFloat, borderColor: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = borderColor.cgColor
    }
    
    func addShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
    }
    
    func animShow() {
        UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.center.y -= self.bounds.width
                        self.layoutIfNeeded()
                       }, completion: nil)
        self.isHidden = false
    }
    
    func animHide() {
        UIView.animate(withDuration: 2, delay: 0, options: [.curveLinear],
                       animations: {
                        self.center.y += self.bounds.width
                        self.layoutIfNeeded()
                        
                       },  completion: {(_ completed: Bool) -> Void in
                        self.isHidden = false
                       })
    }
    
    //Setting Corner Radius
    
    @IBInspectable
    var cornerRadiuss : CGFloat {
        
        get{
            return self.layer.cornerRadius
        }
        
        set(newValue) {
            self.layer.cornerRadius = newValue
        }
        
    }

}

private var rightViews = NSMapTable<UITextField, UIView>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)
private var errorViews = NSMapTable<UITextField, UIView>(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.strongMemory)

extension UITextField {
    
    func setInputViewDatePicker(target: Any, selector: Selector) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        // iOS 14 and above
        if #available(iOS 14, *) {// Added condition for iOS 14
          datePicker.preferredDatePickerStyle = .wheels
          datePicker.sizeToFit()
        }
        self.inputView = datePicker
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel))
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    
    // Add/remove error message
    func setError(_ string: String? = nil, show: Bool = true) {
        if let rightView = rightView, rightView.tag != 999 {
            rightViews.setObject(rightView, forKey: self)
        }
        
        // Remove message
        guard string != nil else {
            if let rightView = rightViews.object(forKey: self) {
                self.rightView = rightView
                rightViews.removeObject(forKey: self)
            } else {
                self.rightView = nil
            }
            
            if let errorView = errorViews.object(forKey: self) {
                errorView.isHidden = true
                errorViews.removeObject(forKey: self)
            }
            
            return
        }
        
        // Create container
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Create triangle
        let triagle = TriangleTop()
        triagle.backgroundColor = .clear
        triagle.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(triagle)
        
        // Create red line
        let line = UIView()
        line.backgroundColor = .red
        line.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line)
        
        let btmView = UIView()
        btmView.backgroundColor = .blue
        btmView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(btmView)
        
        // Create message
        let label = PaddingLabel()
        label.text = string
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont(name: "SFProText-Medium", size: 15)
        label.backgroundColor = .black
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        label.paddingLeft = 10
        label.paddingRight = 10
        label.paddingTop = 5
        label.paddingBottom = 5
        
        // Set constraints for triangle
        triagle.heightAnchor.constraint(equalToConstant: 10).isActive = true
        triagle.widthAnchor.constraint(equalToConstant: 15).isActive = true
        triagle.topAnchor.constraint(equalTo: container.topAnchor, constant: -10).isActive = true
        triagle.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15).isActive = true
        
        // Set constraints for line
        line.heightAnchor.constraint(equalToConstant: 3).isActive = true
        line.topAnchor.constraint(equalTo: triagle.bottomAnchor, constant: 0).isActive = true
        line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0).isActive = true
        line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0).isActive = true
        
        // Set constraints for label
        btmView.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 0).isActive = true
        btmView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0).isActive = true
        btmView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0).isActive = true
        btmView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0).isActive = true
        
        // Set constraints for label
        label.topAnchor.constraint(equalTo: btmView.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: btmView.bottomAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: btmView.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: btmView.trailingAnchor, constant: 0).isActive = true
        
        if !show {
            container.isHidden = true
        }
//        superview!.superview!.addSubview(container)
        UIApplication.shared.keyWindow!.addSubview(container)

        // Set constraints for container
        container.widthAnchor.constraint(lessThanOrEqualTo: superview!.widthAnchor, multiplier: 1).isActive = true
        container.trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: 0).isActive = true
        container.topAnchor.constraint(equalTo: superview!.bottomAnchor, constant: 0).isActive = true
        
        // Hide other error messages
        let enumerator = errorViews.objectEnumerator()
        while let view = enumerator!.nextObject() as! UIView? {
            view.isHidden = true
        }
        
        // Add right button to textField
        let errorButton = UIButton(type: .custom)
        errorButton.tag = 999
        errorButton.setImage(UIImage(named: "ic_error"), for: .normal)
        errorButton.frame = CGRect(x: 0, y: 0, width: frame.size.height, height: frame.size.height)
        errorButton.addTarget(self, action: #selector(errorAction), for: .touchUpInside)
        rightView = errorButton
        rightViewMode = .always
        
        // Save view with error message
        errorViews.setObject(container, forKey: self)
    }
    
    // Show error message
    @IBAction
    func errorAction(_ sender: Any) {
        let errorButton = sender as! UIButton
        let textField = errorButton.superview as! UITextField
        
        let errorView = errorViews.object(forKey: textField)
        if let errorView = errorView {
            errorView.isHidden.toggle()
        }
        
        let enumerator = errorViews.objectEnumerator()
        while let view = enumerator!.nextObject() as! UIView? {
            if view != errorView {
                view.isHidden = true
            }
        }
        
        // Don't hide keyboard after click by icon
//        UIViewController.isCatchTappedAround = false
    }
}

class TriangleTop: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.beginPath()
        context.move(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.minX / 2.0), y: rect.maxY))
        context.closePath()
        
        context.setFillColor(UIColor.red.cgColor)
        context.fillPath()
    }
}

@IBDesignable
class PaddingLabel: UILabel {
    var textEdgeInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textEdgeInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textEdgeInsets))
    }
    
    @IBInspectable
    var paddingLeft: CGFloat {
        set { textEdgeInsets.left = newValue }
        get { return textEdgeInsets.left }
    }
    
    @IBInspectable
    var paddingRight: CGFloat {
        set { textEdgeInsets.right = newValue }
        get { return textEdgeInsets.right }
    }
    
    @IBInspectable
    var paddingTop: CGFloat {
        set { textEdgeInsets.top = newValue }
        get { return textEdgeInsets.top }
    }
    
    @IBInspectable
    var paddingBottom: CGFloat {
        set { textEdgeInsets.bottom = newValue }
        get { return textEdgeInsets.bottom }
    }
}
