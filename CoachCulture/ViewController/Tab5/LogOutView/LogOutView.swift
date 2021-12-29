//
//  LogOutView.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 02/12/21.
//

import UIKit

class LogOutView: UIView {
    
    
    
    
    
    internal var handlerForBtnLogout: (() -> Void)?


    
    public func tapToBtnLogOut(_ handler: @escaping () -> Void)
    {
        self.handlerForBtnLogout = nil
        self.handlerForBtnLogout = handler
    }
    
    
    

    // MARK: - Click Events
    @IBAction func clickToBtnOk(_ sender: UIButton) {
        if handlerForBtnLogout != nil
        {
            handlerForBtnLogout!()
        }
        
       
        
 }

    @IBAction func clickToBtnCancel(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    

}
