/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision high
 * @id py/emailutils
 * @tags security
 *       external/cwe/cwe-20
 */

// 导入Python库，用于分析Python代码
import python

// 导入与Cookie注入相关的查询模块，用于检测用户输入构造Cookie的情况
import semmle.python.security.dataflow.CookieInjectionQuery

// 导入路径图类，用于表示数据流路径
import CookieInjectionFlow::PathGraph

// 定义数据流源节点和汇节点的变量
from CookieInjectionFlow::PathNode source, CookieInjectionFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where CookieInjectionFlow::flowPath(source, sink)

// 选择符合条件的汇节点、源节点和汇节点，并生成相应的结果
select sink.getNode(), source, sink, "Cookie is constructed from a $@.", source.getNode(),  "user-supplied input"