/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/path-injection
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import semmle.python.security.dataflow.new.internal.DataFlowInternal
import semmle.python.security.dataflow.new.internal.DataFlowConfig::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink, DataFlow::TypeTracker::Config config
where
  // 定义数据流源和汇点
  PathInjectionFlow::flowPath(source, sink) and
  // 设置类型跟踪器配置
  config = DataFlow::TypeTracker::config()
select 
  // 选择汇点节点、源节点、路径信息以及描述信息
  sink.getNode(), 
  source, 
  sink, 
  "This path depends on a $@.", 
  source.getNode(), 
  "user-provided value"