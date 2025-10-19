/**
 * @name Server-Side Request Forgery (SSRF)
 * @description An SSRF vulnerability occurs when an application uses unverified input to make requests to a back-end system,
 *              which could allow an attacker to access internal resources without authorization.
 * @id py/ssrf
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @security-severity 8.8
 * @tags security external/cwe/cwe-918
 */

import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
import ServerSideRequestForgeryFlow::PathGraph

from
  ServerSideRequestForgeryFlow::PathNode source,      // 数据流的起始点（来源）
  ServerSideRequestForgeryFlow::PathNode sink         // 数据流的终止点（目标）
where
  ServerSideRequestForgeryFlow::flowPath(source, sink) // 确认存在从source到sink的数据流路径
select
  sink.getNode(),                                     // 返回汇节点的信息
  source,                                             // 返回源节点的信息
  sink,                                               // 返回汇节点的信息
  "SSRF request depends on a $@.",                    // 生成警告消息的格式字符串
  source.getNode(),                                   // 返回源节点的信息
  "user-provided value"                               // 用户提供的值