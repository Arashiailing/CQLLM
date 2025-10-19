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
import semmle.python.security.dataflow.new.internal.dataflow.Interfaces
import semmle.python.security.dataflow.new.internal.dataflow.Diffsets
import semmle.python.security.dataflow.new.internal.dataflow.Barriers
import semmle.python.security.dataflow.new.internal.dataflow.BarrierOps
import semmle.python.security.dataflow.new.internal.dataflow.PrintNode
import semmle.python.security.dataflow.new.internal.dataflow.incremental.IncrementalConfiguration
import semmle.python.security.dataflow.new.internal.dataflow.incremental.FlowDiff
import semmle.python.security.dataflow.new.internal.dataflow.incremental.FlowIncremental

// 导入PathInjectionQuery模块，用于检测路径注入问题
import PathInjectionFlow::PathGraph
// 从PathInjectionFlow模块中导入PathNode类，表示数据流路径中的节点
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"