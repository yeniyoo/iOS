//
//  AnsweredRound.swift
//  Round
//
//  Created by 김윤철 on 2016. 8. 13..
//  Copyright © 2016년 yeniyoo. All rights reserved.
//
/*
 
 이미 유저가 응답한 라운드이다.
 
 */


import Foundation
import ObjectMapper

class AnsweredRound : Round {
    dynamic var yes_no = 0
    dynamic var complete = false
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        yes_no <- map["yes_no"]
        complete <- map["complete"]
    }
}