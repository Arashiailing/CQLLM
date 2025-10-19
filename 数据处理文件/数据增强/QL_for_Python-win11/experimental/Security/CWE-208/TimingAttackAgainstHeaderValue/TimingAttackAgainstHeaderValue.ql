/**
 * @name Timing attack against header value
 * @description Use of a non-constant-time verification routine to check the value of an HTTP header,
 *              possibly allowing a timing attack to infer the header's expected value.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id py/timing-attack-against-header-value
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * A configuration tracing flow from  a client Secret obtained by an HTTP header to a unsafe Comparison.
 */
private module TimingAttackAgainstHeaderValueConfig implements DataFlow::ConfigSig {
  // 定义源节点的谓词，判断是否为客户端提供的敏感信息
  predicate isSource(DataFlow::Node source) { source instanceof ClientSuppliedSecret }

  // 定义汇节点的谓词，判断是否为比较操作的汇节点
  predicate isSink(DataFlow::Node sink) { sink instanceof CompareSink }

  // 定义观察差异增量模式的谓词，这里使用any()表示任何情况都适用
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 定义一个全局的数据流跟踪模块，用于追踪从源到汇的路径
module TimingAttackAgainstHeaderValueFlow =
  TaintTracking::Global<TimingAttackAgainstHeaderValueConfig>;

import TimingAttackAgainstHeaderValueFlow::PathGraph

// 查询语句，查找所有存在潜在时间攻击的路径
from
  TimingAttackAgainstHeaderValueFlow::PathNode source,
  TimingAttackAgainstHeaderValueFlow::PathNode sink
where
  // 条件：存在从源到汇的流动路径，并且汇节点没有进一步流向其他节点
  TimingAttackAgainstHeaderValueFlow::flowPath(source, sink) and
  not sink.getNode().(CompareSink).flowtolen()
select sink.getNode(), source, sink, "Timing attack against $@ validation.", source.getNode(),
  "client-supplied token"
