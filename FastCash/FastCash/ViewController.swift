//
//  ViewController.swift
//  FastCash
//
//  Created by Trevor Carpenter on 10/6/19.
//  Copyright © 2019 Trevor Carpenter. All rights reserved.
//

import UIKit
import PhoneNumberKit

class ViewController: UIViewController {

    
    @IBOutlet weak var textField: PhoneNumberTextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    let phoneNumberKit = PhoneNumberKit()
    
    // variables to track status of phone number
    var isValidNumber = false
    var isForeignNumber = false
    var phoneNumber_e164 = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func nextButtonClick() {
        self.view.endEditing(true)
        let phoneNumber = textField.text ?? ""
        if(phoneNumber == "") {
            errorLabel.text = "Click the textbox to enter a number"
            errorLabel.textColor = UIColor.systemRed
        }
        else if(isForeignNumber) {
            errorLabel.text = "Please enter a US number"
            errorLabel.textColor = UIColor.systemRed
        }
        else if(!isValidNumber) {
            errorLabel.text = "Please enter a valid number"
            errorLabel.textColor = UIColor.systemRed
        } else {
            Api.sendVerificationCode(phoneNumber: self.phoneNumber_e164, completion: { response, error in

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "verification")
                guard let verificationVC = vc as? VerificationViewController else {
                    assertionFailure("couldn't find vc")
                    return
                }
                verificationVC.setPhoneNumber(num: self.phoneNumber_e164)
                self.navigationController?.pushViewController(verificationVC, animated: true)
                
            })
            errorLabel.textColor = UIColor.black
        }
    }
    
    @IBAction func textChange() {
        errorLabel.text = " "
        guard let text = textField.text else {
            self.nextButton.backgroundColor = UIColor.systemGray
            return
        }
        
        do {
            let ph = try phoneNumberKit.parse(text)
            self.isValidNumber = true
            let regId = ph.regionID ?? ""
            print(regId)
            if(regId == "US") {
                self.nextButton.backgroundColor = UIColor.systemGreen
                self.isForeignNumber = false
                self.phoneNumber_e164 = phoneNumberKit.format(ph, toType: .e164)
                
            } else {
                self.nextButton.backgroundColor = UIColor.systemGray
                self.isForeignNumber = true
            }
        } catch {
            self.isValidNumber = false
            self.isForeignNumber = false
            self.nextButton.backgroundColor = UIColor.systemGray
        }
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

