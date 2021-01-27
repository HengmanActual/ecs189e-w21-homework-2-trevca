//
//  Api.swift
//  ECS189E
//
//  Created by Zhiyi Xu on 9/23/18.
//  Copyright © 2018 Sam King. All rights reserved.
//
//  Notes:
//  1. With Api call, you can get response and error.
//     An error contains a code and a message.
//     You do not need to use response for this homework.
//  2. To send out the verification code:
//      Api.sendVerificationCode(phoneNumber: ) { response, error in
//          // .. what you want to do with response or error
//          // .. both response and error can be nil
//      }
//  3. To verify the code:
//      verifyCode(phoneNumber: , code: ) { response, error in
//          // .. what you want to do with response or error
//          // .. both response and error can be nil
//      }
//  4. Error Code => Error Message:
//      "code_expired" => "Your code expired"
//      "incorrect_code" => "Incorrect verification code"
//      "invalid_phone_number" => "Your phone number is invalid"
//  5. You do not have to use the default error message.
//     Test for error code and customize your error message.

import Foundation

struct Api {
    
    private static var phoneNumber: String = "";
    private static let defaultResponse: [String: Any]? = ["status": "ok"]
    
    struct ApiError: Error {
        var message: String
        var code: String
        
        init(response: [String: Any]) {
            self.message = (response["error_message"] as? String) ?? "Network error"
            self.code = (response["error_code"] as? String) ?? "network_error"
        }
    }
    
    typealias ApiCompletion = ((_ response: [String: Any]?, _ error: ApiError?) -> Void)
    
    static var baseUrl = "https://ecs189e-fall2018.appspot.com/api"
    static let defaultError = ApiError(response: [:])
    
    static func ApiCall(endpoint: String, parameters: [String: Any], completion: @escaping ApiCompletion) {
        guard let url = URL(string: baseUrl + endpoint) else {
            print("Wrong url")
            return
        }
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let requestData = try? JSONSerialization.data(withJSONObject: parameters) else {
            DispatchQueue.main.async { completion(nil, defaultError) }
            return
        }

        session.uploadTask(with: request, from: requestData) { data, response, error in
            guard let rawData = data else {
                DispatchQueue.main.async { completion(nil, defaultError) }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: rawData)
            guard let responseData = jsonData as? [String: Any] else {
                DispatchQueue.main.async { completion(nil, defaultError) }
                return
            }

            DispatchQueue.main.async {
                if "ok" == responseData["status"] as? String {
                    completion(responseData, nil)
                } else {
                    completion(nil, ApiError(response: responseData))
                }
            }
        }.resume()
    }
    
    static func testSendVerificationCode(phoneNumber: String, completion: @escaping ApiCompletion) {
        self.phoneNumber = phoneNumber
        DispatchQueue.main.async { completion(defaultResponse, nil) }
    }
    
    static func testVerifyCode(phoneNumber: String, code: String, completion: @escaping ApiCompletion) {
        if phoneNumber == self.phoneNumber && code == "123456" {
            DispatchQueue.main.async { completion(defaultResponse, nil) }
        } else {
            DispatchQueue.main.async { completion(nil, defaultError) }
        }
    }
    
    static func sendVerificationCode(phoneNumber: String, completion: @escaping ApiCompletion) {
        ApiCall(endpoint: "/send_verification_code",
                parameters: ["phone_number": phoneNumber],
                completion: completion)
    }
    
    static func verifyCode(phoneNumber: String, code: String, completion: @escaping ApiCompletion) {
        ApiCall(endpoint: "/verify_code",
                parameters: ["e164_phone_number": phoneNumber, "code": code],
                completion: completion)
    }
}
