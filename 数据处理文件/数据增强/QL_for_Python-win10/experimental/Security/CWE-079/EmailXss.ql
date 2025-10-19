/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page
 *              allows for a cross-site scripting vulnerability.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 2.9
 * @sub-severity high
 * @id py/reflective-xss-email
 * @tags security
 *       experimental
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

// 确定精度
import python
import experimental.semmle.python.security.dataflow.EmailXss
import EmailXssFlow::PathGraph

from EmailXssFlow::PathNode source, EmailXssFlow::PathNode sink
where EmailXssFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "由于 $@ 导致的跨站脚本漏洞。",
  source.getNode(), "用户提供的值"
