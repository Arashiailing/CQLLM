/**
 * @name Timing attack against Hash
 * @description 当检查消息的哈希值时，应使用恒定时间算法。
 *              否则，攻击者可能通过运行时间攻击伪造任意消息的有效哈希值，
 *              如果他们能够发送到验证过程。成功的攻击可能导致身份验证绕过。
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-against-hash
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * 一个配置，用于跟踪从加密操作到等式测试的数据流
 */
private module PossibleTimingAttackAgainstHashConfig implements DataFlow::ConfigSig {
  // 定义数据流的源节点为加密操作调用
  predicate isSource(DataFlow::Node source) { source instanceof ProduceCryptoCall }

  // 定义数据流的汇节点为非恒定时间的比较操作
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }
}

// 定义全局数据流跟踪模块，使用上述配置
module PossibleTimingAttackAgainstHashFlow =
  TaintTracking::Global<PossibleTimingAttackAgainstHashConfig>;

import PossibleTimingAttackAgainstHashFlow::PathGraph

// 查询语句：查找从源节点到汇节点的路径，并选择相关信息进行报告
from
  PossibleTimingAttackAgainstHashFlow::PathNode source,
  PossibleTimingAttackAgainstHashFlow::PathNode sink
where PossibleTimingAttackAgainstHashFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "可能存在针对$@验证的时间攻击。",
  source.getNode().(ProduceCryptoCall).getResultType(), "message"
