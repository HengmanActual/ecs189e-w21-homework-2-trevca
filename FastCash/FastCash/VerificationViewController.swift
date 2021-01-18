//
//  VerificationViewController.swift
//  FastCash
//
//  Created by Trevor Carpenter on 1/18/21.
//  Copyright © 2021 Trevor Carpenter. All rights reserved.
//

import UIKit

class VerificationViewController: UIViewController {

    @IBOutlet weak var OTP1: UITextField!
    @IBOutlet weak var OTP2: UITextField!
    @IBOutlet weak var OTP3: UITextField!
    @IBOutlet weak var OTP4: UITextField!
    @IBOutlet weak var OTP5: UITextField!
    @IBOutlet weak var OTP6: UITextField!
    
    var fields: [UITextField?] = []
    var phoneNum: String = ""
    var currentField = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fields.append(OTP1)
        self.fields.append(OTP2)
        self.fields.append(OTP3)
        self.fields.append(OTP4)
        self.fields.append(OTP5)
        self.fields.append(OTP6)
        self.currentField = 0
        OTP1.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    func setPhoneNumber(num: String) {
        self.phoneNum = num
    }
    
    func concatenateCode()-> String {
        var code = ""
        for field in self.fields {
            code.append(field?.text ?? "")
        }
        return code
    }
    
    @IBAction func editedField(_ sender: Any) {
        print("edited")
        print(self.currentField)
        if self.currentField == 0 {
            let text = self.OTP1.text ?? ""
            if(text.count == 0) {
                return
            }
        }
        if self.currentField == 5 {
            print("verifying")
            Api.verifyCode(phoneNumber: self.phoneNum, code: concatenateCode(), completion: {
                response,error in
                if error == nil {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "home")
                    let homeVC = vc as! HomeViewController

                    self.navigationController?.present(homeVC, animated: true)
                }
                else {
                    print(error)
                }
                
            })
        }
        else {
            // go to next
            self.currentField = self.currentField+1
            self.fields[currentField]?.becomeFirstResponder()
        }
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
