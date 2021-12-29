//
//  ClassDescriptionView.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 18/12/21.
//

import UIKit

class ClassDescriptionView: UIView {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblSubtitle : UILabel!
    @IBOutlet weak var lblDescription : UILabel!

    internal var handlerForBtnOk: (() -> Void)?


    
    public func tapToBtnOk(_ handler: @escaping () -> Void)
    {
        self.handlerForBtnOk = nil
    }
   
    
    @IBAction func clickToBtnOK( _ sender : UIButton) {
        self.removeFromSuperview()
    }

}
