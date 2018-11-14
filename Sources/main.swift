import PerfectLib
import PerfectHTTP
import PerfectHTTPServer


// 注册自己的路由和请求/响应句柄
let networkServer = netWorkServerManager(root: "webroot", port: 8181)
networkServer.startServer()




//var routes = Routes()
//routes.add(method: .get, uri: "/") { (request, response) in
//    response.setHeader(.contentType, value: "text/html")
//    response.appendBody(string: "<html><title>Hello,world!嘻嘻嘻嘻</title><body>Hello,world!嘻嘻嘻嘻</body></html>").completed()
//}
//
//do {
//    // 启动HTTP服务器
//    try HTTPServer.launch(name: "www.example.ca", port: 8181, routes: routes)
//} catch {
//    // fatal error launching one of the servers
//    fatalError("\(error)")
//}

