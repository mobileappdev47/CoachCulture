//
//  LastTransactionTableViewCell.swift
//  CoachCulture
//
//  Created by mac on 19/08/1944 Saka.
//

import UIKit

class LastTransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pointsLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var whereUsePointLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var imgGreenRedIcon: UIImageView!
    @IBOutlet weak var imgMoneyTransaction: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
