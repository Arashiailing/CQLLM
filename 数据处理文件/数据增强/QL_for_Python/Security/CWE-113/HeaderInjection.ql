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

// 导入Python库，用于分析Python代码
import python

// 导入HttpHeaderInjectionQuery模块，该模块包含HTTP头注入相关的查询逻辑
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

// 从HeaderInjectionFlow模块中导入PathGraph类，用于表示路径图
import HeaderInjectionFlow::PathGraph

// 定义数据流源节点和汇节点的变量source和sink
from HeaderInjectionFlow::PathNode source, HeaderInjectionFlow::PathNode sink

// 使用where子句过滤出存在数据流路径的源节点和汇节点对
where HeaderInjectionFlow::flowPath(source, sink)

// 选择符合条件的汇节点、源节点和汇节点，并生成相应的结果
select sink.getNode(), source, sink, "This HTTP header is constructed from a $@.", source.getNode(),
  "user-provided value"
