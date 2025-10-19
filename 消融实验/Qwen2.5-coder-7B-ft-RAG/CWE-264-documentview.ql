/**
 * @name CWE-264:PathInjectionQuery漏洞检测
 * @description 通过用户可控输入构建文件系统路径，可能导致任意文件访问或篡改风险。
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/path-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-22
 *       external/cwe/cwe-23
 *       external/cwe/cwe-36
 *       external/cwe/cwe-73
 *       external/cwe/cwe-99
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(),  "user-provided value"