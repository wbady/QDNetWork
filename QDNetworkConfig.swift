//
//  QDNetworkConfig.swift
//  NetWork
//
//  Created by Apple on 4/9/2024.
//

import Foundation
import Moya


public enum QDNetworkConfig {
    case getTestData
    case createUser(firstName: String, lastName: String)
    case updateUser(id: Int, firstName: String, lastName: String)
    case showAccounts
}


// MARK: - TargetType Protocol Implementation
extension QDNetworkConfig: TargetType {
    public var baseURL: URL {
        switch self {
        case .getTestData:
            return URL(string: "https://www.jianshu.com/shakespeare/notes/14153362/reward_section")!
        case .createUser(_, _), .updateUser(_, _, _), .showAccounts:
            return URL(string: "https://api.QDNetworkConfig.com")!
        }
    }
    
    public var path: String {
        switch self {
        case .getTestData:
            return ""
        case .updateUser(let id, _, _):
            return "/users/\(id)"
        case .createUser(_, _):
            return "/users"
        case .showAccounts:
            return "/accounts"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getTestData:
            return .get
        case .showAccounts:
            return .get
        case .createUser, .updateUser:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .getTestData:
            return .requestPlain
        case .showAccounts: // Send no parameters
            return .requestPlain
        case let .updateUser(_, firstName, lastName):  // Always sends parameters in URL, regardless of which HTTP method is used
            return .requestParameters(parameters: ["first_name": firstName, "last_name": lastName], encoding: URLEncoding.queryString)
        case let .createUser(firstName, lastName): // Always send parameters as JSON in request body
            return .requestParameters(parameters: ["first_name": firstName, "last_name": lastName], encoding: JSONEncoding.default)
        }
    }
    
    // 单元测试
    public var sampleData: Data {
        switch self {
        case .getTestData:
            return "".utf8Encoded
        case .createUser(let firstName, let lastName):
            return "{\"id\": 100, \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".utf8Encoded
        case .updateUser(let id, let firstName, let lastName):
            return "{\"id\": \(id), \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".utf8Encoded
        case .showAccounts:
            // Provided you have a file named accounts.json in your bundle.
            guard let url = Bundle.main.url(forResource: "accounts", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        }
    }
    
    public var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
        
//    Moya允许你通过`ValidationType`枚举配置Alamofire验证功能。
    public var validationType: ValidationType {
        switch self {
        case .getTestData:
            return .none
        case .createUser(firstName: let firstName, lastName: let lastName):
               return .none
        case .updateUser(id: let id, firstName: let firstName, lastName: let lastName):
            return .none
        case .showAccounts:
            return .none
        }
    }
}



