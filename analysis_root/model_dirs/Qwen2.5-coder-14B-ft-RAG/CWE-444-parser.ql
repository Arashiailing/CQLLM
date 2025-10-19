/**
 * @name CWE-444: Inconsistent Interpretation of HTTP Requests ('HTTP Request/Response Smuggling')
 * @description Detects vulnerabilities where improper handling of Content-Length and Transfer-Encoding headers
 *              allows attackers to manipulate HTTP request smuggling conditions.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/request-smuggling
 * @tags security
 *       external/cwe/cwe-444
 */

// 导入核心的Python分析库
import python

// 导入专门处理HTTP请求走私漏洞的安全数据流查询模块
import semmle.python.security.dataflow.RequestSmugglingQuery

// 导入用于表示数据流路径图的专用类
import RequestSmugglingFlow::PathGraph