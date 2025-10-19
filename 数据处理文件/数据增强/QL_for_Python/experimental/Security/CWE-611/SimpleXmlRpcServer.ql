/**
 * @name SimpleXMLRPCServer denial of service
 * @description SimpleXMLRPCServer is vulnerable to denial of service attacks from untrusted user input
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @id py/simple-xml-rpc-server-dos
 * @tags security
 *       experimental
 *       external/cwe/cwe-776
 */

// 导入Python库，用于分析Python代码
private import python

// 导入Semmle Python概念库，提供Python语言的抽象和模式
private import semmle.python.Concepts

// 导入Semmle API图，用于数据流分析
private import semmle.python.ApiGraphs

// 从DataFlow命名空间中引入CallCfgNode类，表示调用配置节点
from DataFlow::CallCfgNode call
where
  // 查找对SimpleXMLRPCServer类的调用，该类位于xmlrpc模块中
  call = API::moduleImport("xmlrpc").getMember("server").getMember("SimpleXMLRPCServer").getACall()
select call, "SimpleXMLRPCServer is vulnerable to XML bombs."
