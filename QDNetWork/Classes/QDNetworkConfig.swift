//
//  QDNetworkConfig.swift
//  NetWork
//
//  Created by Apple on 4/9/2024.
//

import Foundation
import Moya
import Alamofire


#if DEBUG
public let baseUrl = "https://qd-app.xyyh.com.cn"
#endif
public let basUrl = "https://qd-app.xyyh.com.cn"

// MARK: 请求结构体
public struct QDNetworkConfigStruct {
    let url: String!
    let path: String!
    let method: Moya.Method!
    let parameters: [String: Any]!
    let encoding: ParameterEncoding!
    public init(url: String! = basUrl, path: String!, method: Moya.Method = .post, parameters: [String: Any] = [:], encoding: ParameterEncoding = JSONEncoding.default) {
        self.url = url
        self.path = path
        self.method = method
        self.parameters = parameters
        self.encoding = encoding
    }
}

public enum QDNetworkConfig {
    case getTestData
    case createUser(firstName: String, lastName: String)
    case updateUser(id: Int, firstName: String, lastName: String)
    case showAccounts
    case anyType(name: QDNetworkConfigStruct)
}


// MARK: - TargetType Protocol Implementation
extension QDNetworkConfig: TargetType {
    public var baseURL: URL {
        switch self {
        case .getTestData:
            return URL(string: "https://www.jianshu.com/shakespeare/notes/14153362/reward_section")!
        case .createUser(_, _), .updateUser(_, _, _), .showAccounts:
            return URL(string: "https://api.QDNetworkConfig.com")!
        case .anyType(name: let name):
            return URL(string: name.url)!
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
        case .anyType(name: let name):
            return name.path
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
        case .anyType(name: let name):
            return name.method
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
        case .anyType(name: let name):
            return .requestParameters(parameters: name.parameters, encoding: name.encoding)
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
        case .anyType(name: _):
            return "".utf8Encoded
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
        case .createUser(firstName: _, lastName: _):
               return .none
        case .updateUser(id: _, firstName: _, lastName: _):
            return .none
        case .showAccounts:
            return .none
        case .anyType(name: _):
            return .none
        }
    }
}

/// json to model
///  kJson2Model(json: jsonStr, type: model.self)
public func kJson2Model<T: Decodable>(json: String, type: T.Type) -> T? {
    if let jsonData = json.data(using: .utf8) {
        do {
            return try JSONDecoder().decode(type, from: jsonData)
        } catch {
            return nil
        }
    }
    return nil
}

/// json to model
///  kDic2Model(dic: dic, type: model.self)
//public func kDic2Model<T: Decodable>(dic: [AnyHashable: Any]?, type: T.Type) -> T? {
//    let str = dic?.toJSON() ?? ""
//    return kJson2Model(json: str, type: type)
//}

/// data to model
///  kJson2Model(json: data, type: model.self)
public func kData2Model<T: Codable>(data: Data, type: T.Type) -> T? {
    do {
        return try JSONDecoder().decode(type, from: data)
    } catch {
        return nil
    }
}

/// model to json
public func kModel2Json<T: Codable>(model: T) -> String? {
    do {
        let jsonData = try JSONEncoder().encode(model)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
    } catch {
    }
    return nil
}

// model to data
public func kModel2Data<T: Codable>(model: T) -> Data? {
    do {
        return try JSONEncoder().encode(model)
    } catch {
    }
    return nil
}
