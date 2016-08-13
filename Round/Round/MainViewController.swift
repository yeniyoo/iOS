//
//  MainViewController.swift
//  Round
//
//  Created by 김윤철 on 2016. 7. 28..
//  Copyright © 2016년 yeniyoo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIGestureRecognizerDelegate {

    //카드 뷰를 따로 만들어서, 3개 정도 붙여 놓고 하나하나 이으면서 스와이프 하는 방식으로? 느릴까나ㅠㅠ
    

    //사용자가 화면을 스와이프 했을 경우
    //2개의 케이스로 나눈다.
    //상하 - 다른 카드 불러오기
    //좌우 - YES/NO 선택

    @IBAction func swipeAction(sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {

            
            //상하 - 새로운 카드 가져오기
        case UISwipeGestureRecognizerDirection.Up :
            print("up")
            
        case UISwipeGestureRecognizerDirection.Down :
            print("down")
            
        default :
            break
        }
        
    }
    
    //위, 아래 스와이프 - 새 라운드를 가져온다.
    func getNewRound() {
        
    }
    
    
    //랜덤으로 라운드를 3개 정도 불러와,
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
