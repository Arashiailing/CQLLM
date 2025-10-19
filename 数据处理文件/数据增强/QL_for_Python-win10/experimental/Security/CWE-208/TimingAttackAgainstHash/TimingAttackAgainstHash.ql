/**
 * @name Timing attack against Hash
 * @description 当检查消息的哈希值时，应使用恒定时间算法。
 *              否则，攻击者可能通过运行时间攻击伪造任意消息的有效哈希值，
 *              如果他们能够发送到验证过程的话。成功的攻击可能导致身份验证绕过。
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/timing-attack-against-hash
 * @tags security
 *       external/cwe/cwe-208
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import experimental.semmle.python.security.TimingAttack

/**
 * 一个配置，用于跟踪从加密操作到相等性测试的数据流。
 */
private module TimingAttackAgainstHashConfig implements DataFlow::ConfigSig {
  // 定义数据流的源节点为加密调用产生的节点
  predicate isSource(DataFlow::Node source) { source instanceof ProduceCryptoCall }

  // 定义数据流的汇节点为非恒定时间的比较操作节点
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }
}

// 定义全局的数据流跟踪模块，使用上述配置
module TimingAttackAgainstHashFlow = TaintTracking::Global<TimingAttackAgainstHashConfig>;

import TimingAttackAgainstHashFlow::PathGraph

// 查询语句：查找从源节点到汇节点的路径，并选择包含用户输入的汇节点
from TimingAttackAgainstHashFlow::PathNode source, TimingAttackAgainstHashFlow::PathNode sink
where
  // 条件1：存在从源节点到汇节点的数据流路径
  TimingAttackAgainstHashFlow::flowPath(source, sink) and
  // 条件2：汇节点包含用户输入
  sink.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // 选择结果包括汇节点、源节点、汇节点、描述信息、消息类型
  sink.getNode(), source, sink, "Timing attack against $@ validation.",
  source.getNode().(ProduceCryptoCall).getResultType(), "message"
