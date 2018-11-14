//
//  DataBaseManager.swift
//  swiftServiceTest
//
//  Created by 曹诚飞 on 2018/5/16.
//

import PerfectMySQL

// 显然用户名和密码需要根据您自己安装的数据库来决定
let testHost = "127.0.0.1"
let testUser = "root"
let testPassword = "@Caochengfei123"
let testDataBase = "swift_test"
let testTableName = "account_level"


open class DataBaseManager {
    fileprivate var mysql : MySQL!
    init() {
        mysql = MySQL()
        guard connectDataBase() else {
            return
        }
    }
}

/**
 有两种通用的方法可以用于连接MySQL。第一种是，首先跳过选择具体的数据库Schema（指的是MySQL内用户可以创建多个Schema，具体的数据表格是保存在Schema中——译者注），这么做的好处是可以在之后的程序内选择具体的数据库Schema，特别适用于您的程序如果需要操作多个Schema：
 */
/**
 另外一种方式是在连接数据库时将具体的数据库Schema选择作为参数直接传入创建连接的调用过程，不必单独在数据连接后才选择Schema：
 */


extension DataBaseManager {
    
    
    func testStart() {
        let names = ["普通会员","白银会员","黄金会员","白金会员","钻石会员"]
        for index in 0...4 {
            let level_id = index
            let name = names[index]
            let result = insertDataBaseSQL(tableName: testTableName, key: "level_id,name", value: "\(level_id),\(name)")
            if result.success == true {
                print("插入成功")
            }
        }
    }
    
    //  连接数据库
    fileprivate func connectDataBase() -> Bool {
        // 创建MySQL实例
        let mysql = MySQL()
        let connected = mysql.connect(host: testHost, user: testUser, password: testPassword)
        guard connected else {
            print(mysql.errorMessage())
            return false
        }
        return true
    }
    
    func mysqlStatement(_ sql: String) -> (success: Bool, mysqlResult:MySQL.Results?, errorMsg: String?) {
//        guard mysql.selectDatabase(named: testDataBase) else {
//            return (false,nil,"未找到\(testDataBase)数据库")
//        }
        
        let successQuery = mysql.query(statement: sql)
        guard successQuery else {
            return (false,nil,"SQL失败: \(sql)")
        }
        return (true,mysql.storeResults(),"SQL成功: \(sql)")
    }
    
    // MARK: - 增
    
    /// 增
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - key: (键,键,键...) 元组
    ///   - value: (值,值,值...)值 元组
    /// - Returns: 元组
    func insertDataBaseSQL(tableName: String, key: String, value: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String?) {
        let sql = "INSERT INTO \(tableName) (\(key)) VALUES (\(value))"
        return mysqlStatement(sql)
    }
    
    // MARK: - 删
    
    /// 删
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - key: 键
    ///   - value: 值
    /// - Returns: 元组
    func deleteDataBaseSQL(tableName: String, key: String, value: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String?) {
        let sql = "DELETE FROM \(tableName) WHERE \(key) = '\(value)'"
        return mysqlStatement(sql)
    }
    
    // MARK: - 改
    
    /// 改
    ///
    /// - Parameters:
    ///   - tableName: 表明
    ///   - keyValue: 键值对( 键='值', 键='值', 键='值' )
    ///   - whereKey: 条件key
    ///   - whereValue: 条件value
    /// - Returns: 元组
    func updateDataBaseSQL(tableName: String, keyValue: String,whereKey: String, whereValue: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String?) {
        let sql = "UPDATE \(tableName) SET \(keyValue) WHERE \(whereKey) = '\(whereValue)'"
        return mysqlStatement(sql)
    }
    
    // MARK: - 查所有
    /// 查所有
    ///
    /// - Parameter tableName: 表名
    /// - Returns: 元组
    func selectAllDataBaseSQL(tableName: String) ->  (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String?){
        let sql = "SELECT * FROM \(tableName)"
        return mysqlStatement(sql)
    }
    
    // MARK: - 查Where
    /// 查Where
    ///
    /// - Parameters:
    ///   - tableName: 表名
    ///   - keyValue: 键值对
    /// - Returns: 元组
    func selectAllDataBaseSQLWhere(tableName: String, keyValue: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String?) {
        let sql = "SELECT * FROM \(tableName) WHERE \(keyValue)"
        return mysqlStatement(sql)
    }
    
    func mysqlGetTestDataResult() -> [Dictionary<String,String>]? {
        let result = selectAllDataBaseSQL(tableName: testTableName)
        var resultArray = [Dictionary<String,String>]()
        var dict = [String:String]()
        result.mysqlResult?.forEachRow(callback: { (element) in
            dict["accountLevelID"] = element[0]
            dict["name"] = element[1]
            resultArray.append(dict)
        })
        return resultArray
    }

    
    func fetchData() {
        // 创建MySQL实例
        let mysql = MySQL()
        let connected = mysql.connect(host: testHost, user: testUser, password: testPassword)
        guard connected else {
            print(mysql.errorMessage())
            return
        }

        guard mysql.selectDatabase(named: testDataBase) else {
            print("message : 数据库选择失败。错误代码：\(mysql.errorCode()) 错误解释：\(mysql.errorMessage())")
            return
        }
        
        //        defer {
        //            // 这个延后操作能够保证在函数结束时无论什么结果都会自动关闭数据库连接
        //            // 已经弃用
        //            mysql.close()
        //        }
    }
    
//    func fetchData() {
//        // 创建MySQL实例
//        let mysql = MySQL()
//        let connected = mysql.connect(host: testHost, user: testUser, password: testPassword, db: testDataBase)
//        guard connected else {
//            print(mysql.errorMessage())
//            return
//        }
//
//        //        defer {
//        //            // 这个延后操作能够保证在函数结束时无论什么结果都会自动关闭数据库连接
//        //            // 已经弃用
//        //            mysql.close()
//        //        }
//
//    }
    
    /**
     创建数据表格
     Perfect允许在程序内创建表格。进一步继续前面的例子，很容易实现创建表格的操作
     */

    func setupMySQLDB() {
        let mysql = MySQL()
        let connected = mysql.connect(host: testHost, user: testUser, password: testPassword, db: testDataBase)
        guard connected else {
            print(mysql.errorMessage())
            return
        }
        defer {
            mysql.close()
        }
        
        let sql = "CREATE TABLE IF NOT EXISTS \(testTableName) (level_id INT PRIMARY KEY NOT NULL, name VARCHAR(64))"
        guard mysql.query(statement: sql) else {
            print(mysql.errorMessage())
            return
        }
        print("创建成功")
    }
}






