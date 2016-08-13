//
//  RoundHTTPManager.swift
//  Round
//
//  Created by 김보라 on 2016. 8. 13..
//  Copyright © 2016년 yeniyoo. All rights reserved.
//

/*
 
 서버와 HTTP 통신하는데 사용하는 매니져.
 싱글톤으로 사용한다.
 Reactive를 사용하려고 노력하고 있다.
 
 */


import Foundation
import ReactiveCocoa
import FBSDKCoreKit
import FBSDKLoginKit
import AccountKit
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON

class RoundHTTPManager {
    //서버 주소
    let baseurl = "http://f8d9cee0.ngrok.io/api" //"http://df2ed8b2.ngrok.io/api/"   //"http://yeround.mooo.com/api/"
    var loginToken = "" //로그인 혹은 유저 인증이 필요한 경우 사용하는 토큰
    //필요할 때만 생성한다
    //나름 싱글톤...?
    static let sharedInstance = RoundHTTPManager()
    
    private init() {
    }
    
    //MARK: Facebook 로그인
    //로그인 결과를 반환하는 시그널프로듀서를 반환한다.
    func racFaceBookLogin(access_token : String) -> SignalProducer<Bool, NSError>{
        return SignalProducer {
            (observer, error) in
            let loginURL = "/users/facebook-auth"
            let url = self.baseurl + loginURL
            let param = ["access_token" : access_token]
            
            Alamofire.request(.POST, url, parameters:  param)
                .validate()
                .responseString(completionHandler: { (response) in
                    
                    debugPrint(response)
                    
                    switch response.result {
                    
                    case .Success:
                        //서버에서 로그인 성패에 따라 보내는 에러도 달라지게 한다.
                        //auth token 반환 시도
                                if let auth_token = response.response?.allHeaderFields["auth-token"] as? String{
                                    
                                    //토큰을 유저 디폴트에 저장한다.
                                    let userDefault = NSUserDefaults.standardUserDefaults()
                                    self.loginToken = auth_token
                                    userDefault.setObject(auth_token, forKey: "auth_token")
                                    observer.sendNext(true)
                                    
                                }
                                else {
                                    //실패시
                                    let error = NSError(domain: "인증 토큰을 반환하는 데 실패했습니다.", code: 102, userInfo: nil)
                                    observer.sendFailed(error)
                                }
                        
                    case .Failure(let error):
                        let e = NSError(domain: "서버와의 통신에 실패했습니다. \(error.localizedDescription)", code: 100, userInfo: nil)
                        observer.sendFailed(e)
                    
                    }
            
            })
        }
    }
    
    //MARK: 나이설정
    //나이설정의 성패 여부를 돌려준다.
    func racSetUserAge(age : Int) -> SignalProducer<AnyObject, NSError>{
        return SignalProducer { observer, error in
    
            let setAgeURL = "/users"
            
            let url = self.baseurl + setAgeURL
            let headers = ["Authorization" : self.loginToken]
            let param = ["age" : age]
            
            Alamofire.request(.PUT, url, parameters: param, headers: headers)
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                    
                case .Success:
                    
                    //연령대 변경을 시도한다.
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        let status = json["status"]
                        let code = status["code"].number as! Int
                      
                        switch(code) {
                        case 1: // 실패시
                            let error = NSError(domain: NSURLErrorDomain, code: 101, userInfo: nil)
                            observer.sendFailed(error)
                        case 0: //성공시
                            //변경이 성공한 것을 저장한다.
                            
                            let userDefault = NSUserDefaults.standardUserDefaults()
                            userDefault.setInteger(age, forKey: "age")
                            observer.sendCompleted()
                            
                        default :
                            break
                        }
                    }
                case .Failure(let error):
                    let e = NSError(domain: error.domain, code: 100, userInfo: nil)
                    observer.sendFailed(e)
                }
            })
            
        }
    }
    
    
    //MARK: 백그라운드 이미지 Url 리스트 가져오기
    //가져온 백그라운드 이미지 리스트는 []의 배열로 가져온다.
    func racGetBackgroundImageUrlList() -> SignalProducer<AnyObject, NSError> {
        return SignalProducer {
            observer, error in
            
            let getBackgroundUrl = "/background-image"
            
            let url = self.baseurl + getBackgroundUrl
            
            Alamofire.request(.GET, url)
                .validate()
                .responseJSON(completionHandler: { (response) in
                
                    switch response.result {
                        
                    case .Success:
                        
                        if let value = response.result.value {
                            
                            
                            
                            let json = JSON(value)
                            
                            let status = json["status"]
                            let code = status["code"].number as! Int
                            
                            switch(code) {
                            case 1: // 실패시
                                let error = NSError(domain: NSURLErrorDomain, code: 101, userInfo: nil)
                                observer.sendFailed(error)
                            case 0: //성공시
                                
                                let urlList = json["data"].arrayObject as! [[String : AnyObject]]
                                observer.sendNext(urlList)
                                
                            default :
                                break
                            }
                        }
                    case .Failure(let error):
                        let e = NSError(domain: error.domain, code: 100, userInfo: nil)
                        observer.sendFailed(e)
                    }

                    
            })
            
            
        }
    }
    
    //MARK:- 라운드 관련
    
    //MARK: 라운드 가져오기
    func racGetRound() -> SignalProducer<AnyObject, NSError> {
        return SignalProducer {
              observer, error in

            let getRoundURL = "/rounds"
            
            let url = self.baseurl + getRoundURL
            
            Alamofire.request(.GET, url)
                .validate()
                .responseObject(completionHandler: { (response : Response<Round, NSError>) in
                    
                    switch response.result {
                        
                    case .Success:
                        
                        if let value = response.result.value {
                            
                                observer.sendNext(value)
                                observer.sendCompleted()
                            
                        }
                    case .Failure(let error):
                        let e = NSError(domain: error.domain, code: 100, userInfo: nil)
                        observer.sendFailed(e)
                    }
                })
        }
    }
    
    
    //MARK: 라운드 열기. 결과를 Bool로 반환
    func racOpenRound(question : String, background_id : Int) -> SignalProducer<Bool, NSError> {
        return SignalProducer {
            observer, error in
            
            let headers = ["Authorization" : self.loginToken]
            let param : [String : AnyObject] = ["question" : question,
                "background_id" : background_id]
            let openRoundURL = "/rounds"
            
            let url = self.baseurl + openRoundURL
            
            Alamofire.request(.POST, url, parameters: param, headers : headers)
            .validate()
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                        
                    case .Success:
                        
                        if let value = response.result.value {
                            
                            
                            
                            let json = JSON(value)
                            
                            let status = json["status"]
                            let code = status["code"].number as! Int
                            
                            switch(code) {
                            case 1: // 실패시
                                let error = NSError(domain: NSURLErrorDomain, code: 101, userInfo: nil)
                                observer.sendFailed(error)
                            case 0: //성공시
                                
                                observer.sendNext(true)
                                observer.sendCompleted()
                                
                            default :
                                break
                            }
                        }
                    case .Failure(let error):
                        let e = NSError(domain: error.domain, code: 100, userInfo: nil)
                        observer.sendFailed(e)
                    }
                    

            })
            
        }
    }
    
    
    //MARK: 라운드 결과 선택
    func racPick(round_id : Int, yes_no : Bool) ->SignalProducer<AnyObject, NSError>{
        
        return SignalProducer {
            observer, error in
            
        let pickURL = "/picks"
        
        let url = self.baseurl + pickURL
        
        let headers = ["Authorization" : self.loginToken]
        let param : [String : AnyObject] = ["round_id" : round_id,
                                            "yes_no" : yes_no]
        
        Alamofire.request(.POST, url, parameters: param, headers : headers)
        .validate()
        .responseString { (response) in
            
            switch response.result {
            case .Success :
                //이 이후에는 더 이상 넘길 인자가 없으므로 그냥 completed로
                observer.sendCompleted()
            case .Failure(let error) :
                observer.sendFailed(error)
            }
        }
        }
    }
    
    //MARK: 유저가 참여한 라운드 리스트
    func racPickedRoundList() -> SignalProducer<[AnsweredRound], NSError> {
        
        return SignalProducer {
            observer, error in
            
            let pickURL = "/picks"
            
            let url = self.baseurl + pickURL
            
            let headers = ["Authorization" : self.loginToken]
            Alamofire.request(.GET, url, headers : headers)
                .validate()
                .responseArray() { (response : Response<[AnsweredRound], NSError>) in
                    
                    switch response.result {
                    case .Success :
                        
                        if let list = response.result.value {
                        observer.sendNext(list)
                        observer.sendCompleted()
                        }
                        else {
                            let error = NSError(domain: "cannot parsr to [AnsweredRound]", code: 101, userInfo: nil)
                            observer.sendFailed(error)
                        }
                    case .Failure(let error) :
                        observer.sendFailed(error)
                    }
            }
        }

    }
    
}
