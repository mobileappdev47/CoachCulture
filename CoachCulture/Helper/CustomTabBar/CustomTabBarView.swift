//
//  CustomTabBarView.swift
//  FitProHub
//
//  Created by Sunil Zalavadiya on 07/05/18.
//  Copyright © 2018 Sunil Zalavadiya. All rights reserved.
//

import UIKit

protocol CustomTabBarViewDelegate {
    func tabSelectedAtIndex(tabIndex: Int)
}

class CustomTabBarView: UIView
{
    //MARK: - All outlets
    @IBOutlet var btnTabs: [UIButton]!
    @IBOutlet var imgTabs: [UIImageView]!
    @IBOutlet weak var btnTabHeightConstraint: NSLayoutConstraint!
    
    //MARK: - All variables
    var delegate: CustomTabBarViewDelegate?
    
    var selectedIndex: Int = 0
    var normalColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var selectedColor = #colorLiteral(red: 0.8, green: 0.1607843137, blue: 0.2117647059, alpha: 1)
    
    //MARK: -
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initializeSetup()
        
    }
    
    //MARK: - All methods
    private func initializeSetup()
    {
        
        for btn in imgTabs
        {
            let btnIconImage = btn.image
            btn.image = btnIconImage?.tintWithColor(normalColor)
            btn.highlightedImage = btnIconImage?.tintWithColor(selectedColor)

        }
        
        
//        for btn in btnTabs
//        {
//
//            let btnIconImage = btn.imageView!.image!
//
//            btn.setImage(btnIconImage.tintWithColor(normalColor), for: .normal)
//            btn.setImage(btnIconImage.tintWithColor(selectedColor), for: .selected)
//        }
    }
    
    func selectTabAt(index: Int)
    {
        selectedIndex = index
        
        for btn in btnTabs
        {
            if(btn.tag == index)
            {
                btn.isSelected = true
            }
            else
            {
                btn.isSelected = false
            }
        }
        
        for btn in imgTabs
        {
            if(btn.tag == index)
            {
                btn.isHighlighted = true
            }
            else
            {
                btn.isHighlighted = false
            }
        }
        
        delegate?.tabSelectedAtIndex(tabIndex: selectedIndex)
    }
    
    //MARK: - All button click events
    @IBAction func onBtnTab(_ sender: UIButton)
    {
        selectedIndex = sender.tag
        
        selectTabAt(index: selectedIndex)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
