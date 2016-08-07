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
        
        
        //로그인이 되지 않았을 때만 로그인을 하는 페이지가 보이도록 한다.
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
        
        
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            print("Not logged in..")
        }
        else
        {
            //로그인 되어 있는 경우는 바로 다음으로 넘어간다.
            //메인 화면으로 넘어간다.
            let mainViewCon = self.storyboard?.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
            
            //
            self.presentViewController(mainViewCon, animated: true, completion: {
                print("welcome to main")
            })
        }
       
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
            connection.addRequest(req, completionHandler: { (reqCon, result, error) in
                
                //JSON으로 온 결과를 사용할 수 있도록 딕셔너리로 파싱해준다.
                let r = result as! [String : String]
                
                //가져온 사용자 정보를 저장한다. 나중에 필요하다면, 다른 Realm이라던가 이런 데 저장해주면 된다!
                let ud = NSUserDefaults.standardUserDefaults()
                ud.setObject(r["gender"] , forKey: "user_gender")
                
                
                //메인 화면으로 넘어간다.
                let mainViewCon = self.storyboard?.instantiateViewControllerWithIdentifier("mainViewController") as! MainViewController
                
                //
                self.presentViewController(mainViewCon, animated: true, completion: { 
                    print("welcome to main")
                })
                
            })
        
            connection.start()
            
        }
        else {
            //로그인 실패, 혹은 취소 시
            let av = UIAlertController(title: "로그인 실패", message: "로그인이 취소 되었습니다.", preferredStyle: .Alert)
            let action = UIAlertAction(title: "확인", style: .Default, handler: { (action) in
                av.dismissViewControllerAnimated(true, completion: {
                })
            })
            av.addAction(action)
            
            self.presentViewController(av, animated: true, completion: { 
                
            })
        }
        
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("user logged out")
    }


}

