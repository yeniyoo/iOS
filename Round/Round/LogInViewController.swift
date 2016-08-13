//
//  ViewController.swift
//  Round
//
//  Created by 김윤철 on 2016. 7. 17..
//  Copyright © 2016년 yeniyoo. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AccountKit
import Alamofire



class LogInViewController: UIViewController ,FBSDKLoginButtonDelegate{


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //로그인이 되지 않았을 때만 로그인을 하는 버튼이 보이도록 한다.
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            print("Not logged in..")
            var loginButton = FBSDKLoginButton()
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            loginButton.center = self.view.center
            loginButton.delegate = self
            self.view.addSubview(loginButton)
        }

    }

    
    override func viewDidAppear(animated: Bool) {
        login(isNew:  false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Facebook login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        //페이스북 로그인 토큰을 사용해서 뭔가를 할까 했지만... 굳이 필요하지 않았던 거 같다. 성별은 퍼블릭이라 그런 건가?
        if let token = result.token {
            
            //페이스북의 Graph API를 사용해서 성별을 받아온다. 문서도 잘 되어 있지 않거나 이해하기 힘드니, 주의!
            let connection = FBSDKGraphRequestConnection()
            let param = ["fields" : "gender"] //성별을 받아온다.
            let req = FBSDKGraphRequest(graphPath: "me", parameters: param, HTTPMethod: "GET")
            
            //리퀘스트와 돌아 온 뒤 할 일을 추가한다.
            connection.addRequest(req, completionHandler: { (reqCon, result, error) in
                
                //JSON으로 온 결과를 사용할 수 있도록 딕셔너리로 파싱해준다.
                let r = result as! [String : String]
                
            //가져온 사용자 정보를 저장한다. 나중에 필요하다면, 다른 Realm이라던가 이런 데 저장해주면 된다!
            let ud = NSUserDefaults.standardUserDefaults()
            ud.setObject(r["gender"] , forKey: "user_gender")
            
            //가져온 토큰으로 로그인을 시도한다.
            self.login(isNew: true)
            })
            
        
            connection.start()
            
        }
        else {
            //로그인 실패, 혹은 취소 시
            loginFailed("로그인이 취소 되었습니다.")
        }
        
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("user logged out")
    }

    
    //로그인 실패시 팝업 뷰를 띄워 준다.
    func loginFailed(reason : String) {
        let alert = UIAlertController(title: "로그인 실패", message: reason, preferredStyle: .Alert)
        let action = UIAlertAction(title: "확인", style: .Cancel, handler: nil)
        alert.addAction(action)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    //로그인을 시도한다.
    func login(isNew isNew : Bool) {
        
        if let token = FBSDKAccessToken.currentAccessToken()
        {
            //페이스북 로그인 되어 있어 토큰이 있는 경우는 바로 라운드 서버에 로그인을 요청한다.
            let tokenString = token.tokenString
            let httpManager = RoundHTTPManager.sharedInstance
            
            httpManager.racFaceBookLogin(tokenString).startWithSignal({ (observer, disposable) in
                observer.observeNext({ (result) in
                    if result {
                        //메인 화면으로 넘어간다.
                        
                        //새로 가입하는 것이라면 == 페이스북 로그인 버튼을 눌렀었다 라면 나이 설정을 한다..
                        if isNew {
                            let age = 20
                            httpManager.racSetUserAge(age).startWithSignal({ (observer, disposable) in
                                
                                //성공시
                                observer.observeCompleted({ 
                                    let mainViewCon = self.storyboard?.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
                                    
                                    
                                    self.presentViewController(mainViewCon, animated: true, completion: {
                                        print("welcome to main")
                                        
                                    })
                                })
                                
                                observer.observeFailed({ (error) in
                                    
                                    let alert = UIAlertController(title: "연령 설정 실패", message: "나이를 설정하는 데 실패했습니다.", preferredStyle: .Alert)
                                    let action = UIAlertAction(title: "확인", style: .Cancel, handler: nil)
                                    alert.addAction(action)
                                    
                                    self.presentViewController(alert, animated: true, completion: nil)
                                })
                                
                            })
                        }
                        else {
                        
                            //아닌 경우 바로 넘어간다.
                        let mainViewCon = self.storyboard?.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
                        
                        
                        self.presentViewController(mainViewCon, animated: true, completion: {
                            print("welcome to main")
                            
                        })
                        }
                        
                    }
                    else {
                        self.loginFailed("알 수 없는 이유로 로그인에 실패하였습니다. 문제가 지속되면 문의해주세요!")
                    }
                    
                })
                observer.observeFailed({ (error) in
                    self.loginFailed(error.localizedDescription)
                })
            })
        }

    }
}

