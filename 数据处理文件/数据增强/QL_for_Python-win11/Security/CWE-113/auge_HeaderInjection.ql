/**
 * @name HTTP Response Splitting
 * @description Writing user input directly to an HTTP header
 *              makes code vulnerable to attack by header splitting.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/http-response-splitting
 * @tags security
 *       external/cwe/cwe-113
 *       external/cwe/cwe-079
 */

// 导入Python分析库，提供Python代码分析的基础功能
import python

// 导入HTTP头注入查询模块，封装了HTTP头注入漏洞的数据流分析逻辑
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

// 从HeaderInjectionFlow模块导入路径图类，用于构建数据流路径图
import HeaderInjectionFlow::PathGraph

// 声明数据流源节点和汇节点变量，分别表示数据流的起点和终点
from HeaderInjectionFlow::PathNode flowSource, HeaderInjectionFlow::PathNode flowSink

// 通过where子句筛选存在数据流传播路径的源节点和汇节点对
where HeaderInjectionFlow::flowPath(flowSource, flowSink)

// 输出符合条件的汇节点、源节点和汇节点，并附带警告消息
select flowSink.getNode(), flowSource, flowSink, "This HTTP header is constructed from a $@.", flowSource.getNode(),
  "user-provided value"