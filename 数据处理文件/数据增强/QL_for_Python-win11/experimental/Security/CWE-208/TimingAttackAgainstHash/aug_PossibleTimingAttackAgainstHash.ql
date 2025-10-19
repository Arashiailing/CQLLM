/**
 * @name Timing attack against Hash
 * @description 验证消息哈希值时必须使用恒定时间算法。
 *              攻击者可通过响应时间差异伪造有效哈希值，
 *              导致身份验证机制被绕过。
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
 * 配置模块：追踪从加密操作到非恒定时间比较的数据流
 */
private module TimingAttackConfig implements DataFlow::ConfigSig {
  // 源：加密操作调用（如哈希生成）
  predicate isSource(DataFlow::Node cryptoOp) { cryptoOp instanceof ProduceCryptoCall }

  // 汇：非恒定时间比较操作
  predicate isSink(DataFlow::Node compareOp) { compareOp instanceof NonConstantTimeComparisonSink }
}

// 全局污点跟踪模块（使用上述配置）
module TimingAttackFlow = TaintTracking::Global<TimingAttackConfig>;
import TimingAttackFlow::PathGraph

// 主查询：检测从加密操作到非恒定时间比较的数据流路径
from
  TimingAttackFlow::PathNode cryptoNode,  // 加密操作节点
  TimingAttackFlow::PathNode compareNode  // 比较操作节点
where 
  TimingAttackFlow::flowPath(cryptoNode, compareNode)
select 
  compareNode.getNode(), 
  cryptoNode, 
  compareNode, 
  "针对$@验证的时间攻击风险",
  cryptoNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"