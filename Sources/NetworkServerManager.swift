//
//  NetworkServerManager.swift
//  swiftServiceTest
//
//  Created by 曹诚飞 on 2018/5/16.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

open class netWorkServerManager {
    fileprivate var server: HTTPServer
    fileprivate var routes = Routes()
    init(root: String, port: UInt16) {
        server = HTTPServer()
//        var routes = Routes(baseUri: "/api")
        configure()
//        configure(routes: &routes)
        server.addRoutes(routes)
        server.serverPort = port
        server.serverName = "www.example.ca"
//        server.documentRoot = root
        server.setResponseFilters([(Filter404(), .high)])
    }
    
    open func startServer() {
        do {
            print("启动服务器")
//            try HTTPServer.launch(name: "webroot", port: 8181, routes: routes)
            try server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("网络错误 \(err) \(msg)")
        } catch {
            print("未知错误")
        }
    }
}

extension netWorkServerManager {
    fileprivate func configure() {
        routes.add(method: .get, uri: "/") { (request, response) in
            response.setHeader(.contentType, value: "text/html, charset=utf-8")
            let jsonDic = ["hello":"world"]
            let jsonString = self.baseResponseBodyJSONData(status: 200, message: "successful", data: jsonDic)
            response.setBody(string: jsonString)
            response.completed()
        }
        
        routes.add(method: .get, uri: "/home") { (request, response) in
            let databaseManager = DataBaseManager()
            databaseManager.setupMySQLDB()
            databaseManager.testStart()
            let result = databaseManager.mysqlGetTestDataResult()
            let jsonString = self.baseResponseBodyJSONData(status: 200, message: "成功", data: result)
            response.setBody(string: jsonString)
            response.completed()
            
        }
    }
    
    func baseResponseBodyJSONData(status: Int, message: String, data: Any!) -> String {
        var result = Dictionary<String,Any>()
        result.updateValue(status, forKey: "status")
        result.updateValue(message, forKey: "message")
        result.updateValue(data, forKey: "data")
        guard let jsonString = try? result.jsonEncodedString() else {
            return ""
        }
        return jsonString
    }
}

struct Filter404: HTTPResponseFilter {
    func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        callback(.continue)
    }
    
    func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        if case .notFound = response.status {
            response.setBody(string: "404 file\(response.request.path)not find")
            response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
            callback(.done)
        } else {
            callback(.continue)
        }
    }
}
