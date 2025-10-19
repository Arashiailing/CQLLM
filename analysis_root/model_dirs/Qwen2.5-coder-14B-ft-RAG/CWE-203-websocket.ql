/**
 * @name CWE-203: Observable Discrepancy
 * @description nan
 * @kind problem
 * @id py/websocket
 */

import python
import semmle.python.ApiGraphs

// 定义WebSocket API节点
private API::Node websocket_api(string fully_qualified_name) {
  (
    // WebSocket客户端API
    result = API::moduleImport("websocket").getMember("client")
    or
    // WebSocket服务器API
    result = API::moduleImport("websocket").getMember("server")
    or
    // WebSocket主模块API
    result = API::moduleImport("websocket")
  ) and
  // 过滤掉非WebSocket相关的模块
  exists(string prefix |
    fully_qualified_name.prefix(prefix) and
    prefix in [
      "websocket",
      "websocket.client",
      "websocket.server"
    ]
  )
}

// 定义WebSocket连接操作
private API::Node websocket_connection_operation(string operation_name) {
  // 客户端连接操作
  result = websocket_api("websocket.client").getMember("WebSocket").getReturn()
   .getMember(operation_name)
   .getReturn()
  or
  // 服务器连接操作
  result = websocket_api("websocket.server").getMember("WebSocketServer").getReturn()
   .getMember(operation_name)
   .getReturn()
}

// 获取WebSocket连接构造函数
predicate websocket_connection_constructor(API::Node connection_node) {
  connection_node = websocket_connection_operation("__init__")
}

// 获取WebSocket连接实例
predicate websocket_connection_instance(API::Node connection_node) {
  websocket_connection_constructor(connection_node.(API::CallNode).getAnArg(0))
}