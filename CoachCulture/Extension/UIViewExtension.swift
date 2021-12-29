
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
    
}
