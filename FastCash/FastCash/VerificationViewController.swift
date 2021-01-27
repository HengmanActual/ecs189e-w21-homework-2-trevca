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
    @IBOutlet weak var ErrorLabel: UILabel!
    
    @IBOutlet weak var sentToNumber: UILabel!
    
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
        sentToNumber.text? = "Code was sent to \(self.phoneNum)"
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
    
    func clearCodes() {
        for OTP in self.fields {
            OTP?.text = ""
        }
        self.OTP1.becomeFirstResponder()
        self.currentField = 0
    }
    
    @IBAction func editedField(_ sender: Any) {
        print("edited")
        print(self.currentField)
        
        // extra if to help with OTP
        if self.currentField == 0 {
            let text = self.OTP1.text ?? ""
            if(text.count == 0) {
                return
            }
        }
        if self.currentField == 5 {
            let text = self.OTP5.text ?? ""
            if(text.count == 0) {
                self.currentField -= 1
                self.fields[currentField]?.becomeFirstResponder()
            } else {
                print("verifying")
                Api.verifyCode(phoneNumber: self.phoneNum, code: concatenateCode(), completion: {
                    response,error in
                    if error == nil {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "home")
                        guard let homeVC = vc as? HomeViewController else {
                            assertionFailure("couldn't find vc")
                            return
                        }

                        self.navigationController?.present(homeVC, animated: true)
                    }
                    else {
                        self.clearCodes()
                        self.ErrorLabel.text = error?.message
                        self.ErrorLabel.textColor = .systemRed
                    }
                    
                })
            }
            
            
        }
        else {
            // go to next
            let text = self.fields[currentField]?.text ?? ""
            if(text.count == 0 && currentField > 0) {
                self.currentField -= 1
                self.fields[currentField]?.becomeFirstResponder()
            } else {
                self.currentField += 1
                self.fields[currentField]?.becomeFirstResponder()
            }
        }
    }
    
    
    @IBAction func resendCode(_ sender: Any) {
        Api.sendVerificationCode(phoneNumber: self.phoneNum, completion: { response, error in
            if let _ = response {
                self.ErrorLabel.text = ""
                self.ErrorLabel.textColor = .black
            }
            if let err = error {
                self.ErrorLabel.text = err.message
                self.ErrorLabel.textColor = .systemRed
            }
        })
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
