//
//  QDNetworkUtil.swift
//  NetWork
//
//  Created by Apple on 4/9/2024.
//

import Foundation
import Alamofire
import Moya

class QDNetworkUtil {
    
    // 网络连接处理
    static var NetworkReachable: Bool {
        get {
            let network = NetworkReachabilityManager()
            return network?.isReachable ?? false
        }
    }
    
    
    static let customEndPointClosure = { (target: QDNetworkConfig) -> Endpoint in
        ///这里把endpoint重新构造一遍主要为了解决网络请求地址里面含有? 时无法解析的bug 
        let url = target.baseURL.absoluteString + target.path
        var task = target.task
        
        var endpoint = Endpoint(
            url: url,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: task,
            httpHeaderFields: target.headers
        )
        return endpoint
    }
    
    
    // 网络请求的设置
    static let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
        do {
            var request = try endpoint.urlRequest()
            //设置请求时长
            request.timeoutInterval = 30
            // 打印请求参数
            if let requestData = request.httpBody {
                print("\(request.url!)"+"\n"+"\(request.httpMethod ?? "")"+"发送参数"+"\(String(data: request.httpBody!, encoding: String.Encoding.utf8) ?? "")")
            }else{
                print("\(request.url!)"+"\(String(describing: request.httpMethod))")
            }
            done(.success(request))
        } catch {
            done(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    /// NetworkActivityPlugin插件用来监听网络请求，界面上做相应的展示
    static let networkPlugin = NetworkActivityPlugin { change, target in
        //targetType 是当前请求的基本信息
        switch(change){
        case .began:
            print("开始请求网络")
        case .ended:
            print("结束")
        }
    }
  
    
    // MARK: - 打印日志
    static let networkLoggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
}



extension URLRequest {
    //TODO：处理公共参数
    private var commonParams: [String: Any]? {
        //所有接口的公共参数添加在这里：
        let header = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Content-type": "application/json;charset=utf-8",
            "systemType": "iOS",
            "version": "1.0.0",
            "token": getToken(),
        ]
        return header
        
    }
    
    private func getToken() -> String {
        return "1234567890"
    }
}


class RequestHandlingPlugin: PluginType {
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var mutateableRequest = request
        return mutateableRequest.appendCommonParams();
    }
    func willSend(_ request: any RequestType, target: any TargetType) {
        
    }
}

extension URLRequest {
    mutating func appendCommonParams() -> URLRequest {
        let request = try? encoded(parameters: commonParams, parameterEncoding: URLEncoding(destination: .queryString))
        assert(request != nil, "append common params failed, please check common params value")
        return request!
    }

    func encoded(parameters: [String: Any]?, parameterEncoding: ParameterEncoding) throws -> URLRequest {
        do {
            return try parameterEncoding.encode(self, with: parameters)
        } catch {
            throw MoyaError.parameterEncoding(error)
        }
    }
}



extension String {
    var urlEscaped: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        Data(self.utf8)
    }
}
