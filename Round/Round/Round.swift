//
//  Round.swift
//  Round
//
//  Created by 김윤철 on 2016. 7. 28..
//  Copyright © 2016년 yeniyoo. All rights reserved.
//

import Foundation
import ObjectMapper

/*
라운드를 저장하는 객체. 라운드에 대한 정보를 가지고 있다.
 */
class Round :  Mappable {
    
    dynamic var question = ""
    dynamic var id = 0
    dynamic var member = 0
    dynamic var created_date = NSDate()
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"
        dateformatter.locale = NSLocale(localeIdentifier: "ko_KR")
        
        question <- map["question"]
        id <- map["id"]
        member <- map["member"]
        created_date <- (map["created_date"], DateFormatterTransform(dateFormatter: dateformatter))
    }
    
}