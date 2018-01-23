//
//  SignupVC.swift
//  WelcomeAR
//
//  Created by tab on 2017/12/18.
//  Copyright © 2017年 tab. All rights reserved.
//

import UIKit

class SignupVC: RootViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var pwdagain: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    
    @IBAction func signup(_ sender: UIButton) {
        if pwd.text == pwdagain.text {
            let user = BmobUser()
            user.username = name.text
            user.password = pwd.text
            user.signUpInBackground({ (signup:Bool, error:Error?) in
                if signup {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            })
        }
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
