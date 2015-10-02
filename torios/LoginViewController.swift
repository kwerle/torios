//
//  LoginViewController.swift
//  torios
//
//  Created by Kurt Werle on 10/1/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUserSession()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.text = UserSession.instance.account.userName
        passwordTextField.text = UserSession.instance.account.password
    }
    
    func initUserSession() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loggedIn", name: UserSession.loginSucceeded, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginFailed", name: UserSession.loginFailed, object: nil)
    }
    
    func loggedIn() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loginFailed() {
        emailTextField.enabled = true
        passwordTextField.enabled = true
        loginButton.enabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login() {
        emailTextField.enabled = false
        passwordTextField.enabled = false
        loginButton.enabled = false
        
        if let name = emailTextField.text, pass = passwordTextField.text {
            UserSession.instance.login(name, pass: pass)
        }
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
