/**
 * @name Timing attack against secret
 * @description Use of a non-constant-time verification routine to check the value of an secret,
 *              possibly allowing a timing attack to retrieve sensitive information.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack
import TimingAttackAgainstSensitiveInfoFlow::PathGraph

/**
 * A configuration tracing flow from obtaining a client Secret to a unsafe Comparison.
 */
private module TimingAttackAgainstSensitiveInfoConfig implements DataFlow::ConfigSig {
  // 定义源节点的谓词，判断节点是否为SecretSource类型
  predicate isSource(DataFlow::Node source) { source instanceof SecretSource }

  // 定义汇节点的谓词，判断节点是否为NonConstantTimeComparisonSink类型
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }

  // 定义增量模式下观察差异的谓词，这里使用any()表示任何情况都满足
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 定义一个全局污点跟踪模块，用于追踪从获取客户端秘密到不安全比较的流动路径
module TimingAttackAgainstSensitiveInfoFlow =
  TaintTracking::Global<TimingAttackAgainstSensitiveInfoConfig>;

// 查询语句，查找从源节点到汇节点的流动路径，并选择相关的节点和信息
from
  TimingAttackAgainstSensitiveInfoFlow::PathNode source,
  TimingAttackAgainstSensitiveInfoFlow::PathNode sink
where
  // 条件：存在从源节点到汇节点的流动路径，并且源节点或汇节点包含用户输入
  TimingAttackAgainstSensitiveInfoFlow::flowPath(source, sink) and
  (
    source.getNode().(SecretSource).includesUserInput() or
    sink.getNode().(NonConstantTimeComparisonSink).includesUserInput()
  )
select sink.getNode(), source, sink, "Timing attack against $@ validation.", source.getNode(),
  "client-supplied token"
