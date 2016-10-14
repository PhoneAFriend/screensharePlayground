//
//  Polyline.swift
//  DrawTogether
//
//  Created by Cody Miller on 10/7/16.
//  Copyright © 2016 seniorDesign. All rights reserved.
//

import UIKit

class Polyline: CBLModel {
    
    @NSManaged var points: [[String : CGFloat]]
    
    init() {
        super.init(document: kDatabase.createDocument())
        
        setValue("polyline", ofProperty: "type")
        self.points = []
    }
    
    override init!(document: CBLDoc!) {
        super.init(document: document)
    }
    
}
