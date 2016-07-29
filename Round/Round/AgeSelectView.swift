//

//  AgeSelectView.swift

//  Round

//

//  Created by garin on 2016. 7. 28..

//  Copyright © 2016년 yeniyoo. All rights reserved.

//

import UIKit



class AgeSelectView : UIViewController, UIActionSheetDelegate{
    
    
    
    let ageTitle = ["10대" , "20대","30대","40대 이상"]
    
    
    
    @IBAction func tapButton(sender : AnyObject) {
        
        var sheet : UIActionSheet = UIActionSheet();
        
        
        
        sheet.title = "당신의 연령층을 선택해주세요"
        
        sheet.delegate = self
        
        
        
        sheet.addButtonWithTitle("취소")
        
        
        
        for title in ageTitle {
            
            sheet.addButtonWithTitle(title)
            
        }
        
        
        
        sheet.cancelButtonIndex = 0
        
        sheet.showInView(self.view)
        
    }
    
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        NSLog("index \(buttonIndex) ")
        
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
}

