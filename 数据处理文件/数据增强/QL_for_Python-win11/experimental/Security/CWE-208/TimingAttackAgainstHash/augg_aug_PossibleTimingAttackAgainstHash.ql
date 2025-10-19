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
 * 配置模块：定义加密操作源与非恒定时间比较汇的数据流追踪规则
 */
private module TimingAttackConfig implements DataFlow::ConfigSig {
  // 源：加密操作调用（如哈希生成）
  predicate isSource(DataFlow::Node cryptoOperation) { 
    cryptoOperation instanceof ProduceCryptoCall 
  }

  // 汇：非恒定时间比较操作
  predicate isSink(DataFlow::Node comparisonOperation) { 
    comparisonOperation instanceof NonConstantTimeComparisonSink 
  }
}

// 全局污点跟踪模块（应用上述配置）
module TimingAttackFlow = TaintTracking::Global<TimingAttackConfig>;
import TimingAttackFlow::PathGraph

// 主查询：检测从加密操作到非恒定时间比较的数据流路径
from 
  TimingAttackFlow::PathNode sourceNode,    // 加密操作源节点
  TimingAttackFlow::PathNode sinkNode       // 非恒定时间比较汇节点
where 
  TimingAttackFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "针对$@验证的时间攻击风险",
  sourceNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"