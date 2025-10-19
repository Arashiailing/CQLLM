/**
 * @name Timing attack against Hash
 * @description 在验证消息哈希值时，必须使用恒定时间算法。
 *              攻击者可能通过分析响应时间的差异来伪造有效的哈希值，
 *              从而绕过身份验证机制。
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
 * 配置模块：定义时间攻击分析的数据流源和汇
 * 源：加密操作调用（如哈希生成）
 * 汇：非恒定时间比较操作
 */
private module TimingAttackAnalysisConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node cryptoOperation) { 
    cryptoOperation instanceof ProduceCryptoCall 
  }

  predicate isSink(DataFlow::Node comparisonOperation) { 
    comparisonOperation instanceof NonConstantTimeComparisonSink 
  }
}

// 基于上述配置的全局污点跟踪模块
module TimingAttackAnalysisFlow = TaintTracking::Global<TimingAttackAnalysisConfig>;
import TimingAttackAnalysisFlow::PathGraph

/**
 * 主查询：识别从加密操作到非恒定时间比较的潜在时间攻击路径
 * 查找所有从加密操作（源）流向非恒定时间比较（汇）的数据流路径
 */
from
  TimingAttackAnalysisFlow::PathNode sourceNode,  // 加密操作节点
  TimingAttackAnalysisFlow::PathNode sinkNode     // 比较操作节点
where 
  TimingAttackAnalysisFlow::flowPath(sourceNode, sinkNode)
select 
  sinkNode.getNode(), 
  sourceNode, 
  sinkNode, 
  "针对$@验证的时间攻击风险",
  sourceNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"