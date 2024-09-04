//
//  QDNetworkService.swift
//  NetWork
//
//  Created by Apple on 4/9/2024.
//

import Foundation
import Moya
import Alamofire

open class QDNetworkService {
    
    // 成功数据回调
    public typealias SuccessCallBack<T> = ((T?)) -> Void
    public typealias successCallBack = ((Data)) -> (Void)
    // 失败的回调
    public typealias failedCallBack = ((String) -> (Void))
    // 网络错误回调
    public typealias errorCallBack = ((String) -> (Void))
    
    public static func request(_ target: QDNetworkConfig, completion: @escaping successCallBack) {
        request(target, completion: completion, failed: nil)
    }
    
    public static func request(_ target: QDNetworkConfig, completion: @escaping successCallBack, failed: failedCallBack?) {
        request(target, completion: completion, failed: failed, errorCallBack: nil)
    }
    
    public static func request(_ target: QDNetworkConfig, completion: @escaping successCallBack, failed: failedCallBack?, errorCallBack: errorCallBack?) {
        request(target, completion: completion, falied: failed, errorCallBack: errorCallBack)
    }
    
    
    @discardableResult
    private static func request(_ target: QDNetworkConfig, completion: @escaping successCallBack, falied: failedCallBack?, errorCallBack: errorCallBack?) -> Cancellable? {
        if !QDNetworkUtil.NetworkReachable {
            return nil
        }
        
        let provider = MoyaProvider<QDNetworkConfig>(endpointClosure: QDNetworkUtil.customEndPointClosure, requestClosure: QDNetworkUtil.requestClosure, plugins: [QDNetworkUtil.networkPlugin, RequestHandlingPlugin(),QDNetworkUtil.networkLoggerPlugin], trackInflights: false)
        return provider.request(target) { result in
            switch result {
            case let .success(response):
                if 200 == response.statusCode {
                    completion(response.data)
                } else {
                    falied?(response.description)
                }
            case let .failure(error):
                errorCallBack?(error.errorDescription ?? "")
            }
        }
    }
}
