//
//  ViewController.swift
//  UITextFieldPlaceholderDemo
//
//  Created by Christina Moulton on 2015-01-27.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit

class WriteViewController: UIViewController, UITextViewDelegate {
    
    var writeTextView: UITextView?
    let PLACEHOLDER_TEXT = "해결하고 싶은 주제를 \n적어주세요."
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // create the textView
        writeTextView = UITextView(frame: CGRect(x: 30, y: 278, width: self.view.frame.size.width - 40, height: 100))
        self.view.addSubview(writeTextView!)
        
        applyPlaceholderStyle(writeTextView!, placeholderText: PLACEHOLDER_TEXT)
        
        // set this class as the delegate so we can handle events from the textView
        writeTextView?.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WriteViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
//    func addBoldText(fullString: NSString, boldPartOfString: NSString, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
//        let nonBoldFontAttribute = [NSFontAttributeName:font!]
//        let boldFontAttribute = [NSFontAttributeName:boldFont!]
//        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
//        boldString.addAttributes(boldFontAttribute, range: fullString.rangeOfString(boldPartOfString as String))
//        return boldString
//    }
    
    // MARK: helper functions
    
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor.lightGrayColor()
        aTextview.backgroundColor = UIColor.clearColor()
       // aTextview.font = UIFont(name: (aTextview.font?.fontName)!, size: 16)
        aTextview.textAlignment = .Center
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.whiteColor()
        aTextview.font = UIFont(name: (aTextview.font?.fontName)!, size: 18)
        aTextview.backgroundColor = UIColor.clearColor()
        aTextview.textAlignment = .Center
        aTextview.alpha = 1.0
    }
    
    func moveCursorToStart(aTextView: UITextView)
    {
        dispatch_async(dispatch_get_main_queue(), {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    // MARK: UITextViewDelegate
    
    func textViewShouldBeginEditing(aTextView: UITextView) -> Bool
    {
        if aTextView == writeTextView && aTextView.text == PLACEHOLDER_TEXT
        {
            // move cursor to start
            moveCursorToStart(aTextView)
        }
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // remove the placeholder text when they start typing
        // first, see if the field is empty
        // if it's not empty, then the text should be black and not italic
        // BUT, we also need to remove the placeholder text if that's the only text
        // if it is empty, then the text should be the placeholder
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 // have text, so don't show the placeholder
        {
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == writeTextView && textView.text == PLACEHOLDER_TEXT
            {
                if text.utf16.count == 0 // they hit the back button
                {
                    return false // ignore it
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(textView, placeholderText: PLACEHOLDER_TEXT)
            moveCursorToStart(textView)
            return false
        }
    }
    
}
