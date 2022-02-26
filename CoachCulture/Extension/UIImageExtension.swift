
import Foundation
import UIKit
import SDWebImage


extension UIImage {
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func fixPortraitOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    
    public enum DataUnits: String {
        case byte, kilobyte, megabyte, gigabyte
    }
    
    func getSizeIn(_ type: DataUnits, recdData: Data)-> Double {
        var size: Double = 0.0
        
        switch type {
            case .byte:
                size = Double(recdData.count)
            case .kilobyte:
                size = Double(recdData.count) / 1024
            case .megabyte:
                size = Double(recdData.count) / 1024 / 1024
            case .gigabyte:
                size = Double(recdData.count) / 1024 / 1024 / 1024
        }
        return size
        //return String(format: "%.2f", size)
    }
    
    func tintWithColor(_ color:UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale);
        //UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        
        // flip the image
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.translateBy(x: 0.0, y: -self.size.height)
        
        // multiply blend mode
        context?.setBlendMode(.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context?.fill(rect)
        
        // create uiimage
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
    
  
}

extension UIImageView {
    
    func setImageFromURL (imgUrl:String,placeholderImage: String?) {
        self.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "coverBG"), options: .retryFailed, context: nil)
    }
}



extension UITextField{
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}



//MARK: - Custom Date Picker View
class CustomDatePickerViewForTextFeild: NSObject
{
    
    fileprivate var textField: UITextField!
    var datePickerView: UIDatePicker!
    fileprivate var formatter: DateFormatter!
    fileprivate var dateFormat: String!
    fileprivate var mode: UIDatePicker.Mode!
    
    fileprivate var minDate: Date!
    fileprivate var maxDate: Date!
    
    internal var handlerForPickedDate: ((String, Date) -> Void)?
    
    init(textField: UITextField, format: String, mode: UIDatePicker.Mode, minDate: Date? = nil, maxDate: Date? = nil) {
        super.init()
        
        self.textField = textField
        self.dateFormat = format
        self.mode = mode
        self.minDate = minDate
        self.maxDate = maxDate
        
        setupDatePicker()
    }
    
    //MARK: - Methods
    
    fileprivate func setupDatePicker() {
        
        formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        datePickerView = UIDatePicker()
        datePickerView.datePickerMode = mode
        
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        datePickerView.minimumDate = minDate
        datePickerView.maximumDate = maxDate
        
       
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        keyboardToolbar.barStyle = .black
        keyboardToolbar.tintColor = UIColor.white
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(clickToKeyboardToolbarDone(_:)))
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let items = [flex, barButtonItem]
        keyboardToolbar.setItems(items, animated: true)
        
        textField.inputAccessoryView = keyboardToolbar
        textField.inputView = datePickerView
                
    }
    
    func setMinimumDate(date: Date) {
        datePickerView.minimumDate = date
    }
    
    func setMaximumDate(date: Date) {
        datePickerView.maximumDate = date
    }
    
    func pickerView(selectionDone handler: @escaping (_ selectedDate: String, Date) -> Void) {
        self.handlerForPickedDate = handler
    }
    
    //MARK: - All Button Click Event
    @IBAction fileprivate func clickToKeyboardToolbarDone(_ sender: UIBarButtonItem) {
        if(textField.isFirstResponder)
        {
            let formatedDateStr = formatter.string(from: datePickerView.date)
            self.handlerForPickedDate?(formatedDateStr, datePickerView.date)
        }
        
        textField.resignFirstResponder()
    }
    
}

