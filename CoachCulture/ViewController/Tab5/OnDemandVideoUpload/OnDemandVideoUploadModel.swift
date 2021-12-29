//
//  OnDemandVideoUploadModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 06/12/21.
//

import Foundation

class ClassTypeList {
    var map: Map!
    var id = ""
    var class_type_name = ""
    var isSelected = false
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        class_type_name = map.value("class_type_name") ?? ""
    }
    
    
    class func getData(data : [Any]) -> [ClassTypeList] {
        
        var arrTemp = [ClassTypeList]()
        for temp in data {
       
            arrTemp.append(ClassTypeList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}


class ClassDifficultyList {
    var map: Map!
    var id = ""
    var class_difficulty_name = ""
    var isSelected = false
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        class_difficulty_name = map.value("class_difficulty_name") ?? ""
    }
    
    
    class func getData(data : [Any]) -> [ClassDifficultyList] {
        
        var arrTemp = [ClassDifficultyList]()
        for temp in data {
       
            arrTemp.append(ClassDifficultyList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}


class MuscleList {
    var map: Map!
    var id = ""
    var muscle_group_name = ""
    var isSelected = false
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        muscle_group_name = map.value("muscle_group_name") ?? ""
    }
    
    
    class func getData(data : [Any]) -> [MuscleList] {
        
        var arrTemp = [MuscleList]()
        for temp in data {
       
            arrTemp.append(MuscleList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}

class EquipmentList {
    var map: Map!
    var id = ""
    var equipment_name = ""
    var equipment_id = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        equipment_id = map.value("equipment_id") ?? ""
        equipment_name = map.value("equipment_name") ?? ""
    }
    
    
    class func getData(data : [Any]) -> [EquipmentList] {
        
        var arrTemp = [EquipmentList]()
        for temp in data {
       
            arrTemp.append(EquipmentList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}
