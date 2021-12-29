//
//  AddPhotoPopUp.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 04/12/21.
//

import UIKit

class AddPhotoPopUp: UIView {

    internal var handlerForBtnGallery: (() -> Void)?
    internal var handlerForBtnCamera: (() -> Void)?


    
    public func tapToBtnGallery(_ handler: @escaping () -> Void)
    {
        self.handlerForBtnGallery = nil
        self.handlerForBtnGallery = handler
    }
    
    public func tapToBtnCamera(_ handler: @escaping () -> Void)
    {
        self.handlerForBtnCamera = nil
        self.handlerForBtnCamera = handler
    }
    
    
    @IBAction func clickToBtnGallery() {
        
        if handlerForBtnGallery != nil
        {
            handlerForBtnGallery!()
        }
        
    }
    
    @IBAction func clickToBtnCamera() {
        if handlerForBtnCamera != nil
        {
            handlerForBtnCamera!()
        }
    }


}
