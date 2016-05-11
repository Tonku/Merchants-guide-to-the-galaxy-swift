//
//  ViewController.swift
//  galaxy
//
//  Created by Tony Thomas on 29/04/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {

    //MARK: properties
 
    lazy var transactionManager = TransactionManager()
    
  
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var keyboardViewHeight: NSLayoutConstraint!
    
     //MARK: overrides
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("keyboardWillAppear:") , name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("keyboardWillDisappear:") , name: UIKeyboardWillHideNotification, object: nil)
        
        //This is sample test input, to help running the test
        let inputs = [
            "glob is I",
            "prok is V",
            "pish is X",
            "tegj is L",
            "glob glob Silver is 34 Credits",
            "glob prok Gold is 57800 Credits",
            "pish pish Iron is 3910 Credits",
            "how much is pish tegj glob glob ?",
            "how many Credits is glob prok Silver ?",
            "how many Credits is glob prok Gold ?",
            "how many Credits is glob prok Iron ?",
            "how much wood could a woodchuck chuck if a woodchuck could chuck wood ?",
            "how much is tegj ?"
            
        ]
        inputTextView.text = inputs.reduce("", combine: { (sum, val : String) -> String in
            
            sum + "\n" + val
        })
        
        for input in inputs{
            
            transactionManager.addInput(input)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    func parseInput(inputConditions : String){
        
        
    }
    func executeQuerry(querry : String){
        
        
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    //MARK: Keyboard notifications
    
    func keyboardWillAppear(notification: NSNotification){
        
        if let userInfo = notification.userInfo{
            
            if let keyboardRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(){
                
                keyboardViewHeight.constant = keyboardRect.height
                view.setNeedsLayout()
            }
        }
    }
    
    func keyboardWillDisappear(notification: NSNotification){
        
        keyboardViewHeight.constant = 0;
        view.setNeedsLayout()
    }
    
    func printResult(result :[String]){
        
        
    }
    //MARK: actions
    
    @IBAction func onRunTest(sender: AnyObject) {
        
        self.resultTextView.text = ""
        self.transactionManager.clearState()
        
        let inputs =  inputTextView.text.componentsSeparatedByString("\n").filter { !$0.isEmpty }
        
        for input in inputs{
            
            transactionManager.addInput(input)
        }
        
        //The test will run in background thread and the result is displayed on main thread
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        dispatch_async(backgroundQueue, { [unowned self ] in
            
                self.transactionManager.runTest(
                
                resultCallback: { (result :[String]) in
                    
                    let result =   result.reduce("", combine: { (sum, string : String) -> String in
                        
                        sum + "\n\n" + string
                    })
                    
                    dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                        
                        self.resultTextView.text = result
                        
                        })
             })
            
            
            })
       
        view.endEditing(true)
    }
    
     //MARK: TextViewDelegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if textView == resultTextView{
            
            view.endEditing(true)
            
            return false
        }
        return true
    }
    
}

