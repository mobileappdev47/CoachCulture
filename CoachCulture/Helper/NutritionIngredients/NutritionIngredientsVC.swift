//
//  NutritionIngredientsVC.swift
//  CoachCulture
//
//  Created by Brainbinary Infotech on 31/05/22.
//

import UIKit

protocol NutritionIngredientsDelegate {
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?)
}

class NutritionIngredientsVC: UIViewController {

    static func viewcontroller() -> NutritionIngredientsVC {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "NutritionIngredientsVC") as! NutritionIngredientsVC
        return vc
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: NutritionIngredientsDelegate?
    var arrIngredient = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
}

extension NutritionIngredientsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrIngredient.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NutritionIngredientsCell") as! NutritionIngredientsCell
        cell.lblNutritionIngrients.text = arrIngredient[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("index\(indexPath)")
    }
}

class NutritionIngredientsCell: UITableViewCell {
    @IBOutlet weak var lblNutritionIngrients: UILabel!
}
