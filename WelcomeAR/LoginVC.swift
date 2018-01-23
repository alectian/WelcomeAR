//
//  LoginVC.swift
//  WelcomeAR
//
//  Created by tab on 2017/12/18.
//  Copyright © 2017年 tab. All rights reserved.
//

import UIKit

class LoginVC: RootViewController {
    
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var pwd: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    @IBAction func login(_ sender: UIButton) {
        
        BmobUser.loginWithUsername(inBackground: name.text, password: pwd.text, block: { (user, error) in
            if (user != nil) {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                
            }
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
