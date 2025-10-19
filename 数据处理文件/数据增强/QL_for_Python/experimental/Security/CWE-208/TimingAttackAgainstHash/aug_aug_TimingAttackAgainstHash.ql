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
 * 配置模块：跟踪从加密操作到非恒定时间比较的数据流
 * 该模块定义了数据流分析的源和汇点
 */
private module CryptoTimingAnalysisConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：加密调用产生的节点
   * 这些节点代表可能产生加密值的操作，如哈希函数调用
   */
  predicate isSource(DataFlow::Node cryptoOperationNode) { 
    cryptoOperationNode instanceof ProduceCryptoCall 
  }

  /**
   * 定义数据流汇：非恒定时间的比较操作节点
   * 这些节点代表可能泄露时序信息的比较操作
   */
  predicate isSink(DataFlow::Node timingVulnerableComparisonNode) { 
    timingVulnerableComparisonNode instanceof NonConstantTimeComparisonSink 
  }
}

/**
 * 基于配置的全局污点跟踪模块
 * 用于跟踪从加密操作到非恒定时间比较的数据流
 */
module CryptoTimingAttackFlow = TaintTracking::Global<CryptoTimingAnalysisConfig>;

// 导入路径图用于路径分析
import CryptoTimingAttackFlow::PathGraph

/**
 * 主查询：检测存在安全风险的路径
 * 查找从加密操作到非恒定时间比较的数据流路径，
 * 且比较操作包含用户输入的情况
 */
from CryptoTimingAttackFlow::PathNode cryptoSourceNode, CryptoTimingAttackFlow::PathNode timingSinkNode
where
  // 条件1：存在从加密操作到比较操作的数据流路径
  CryptoTimingAttackFlow::flowPath(cryptoSourceNode, timingSinkNode) and
  // 条件2：比较操作节点包含用户输入，增加了攻击面
  timingSinkNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // 输出格式：汇节点、源节点、路径节点、描述信息、消息类型
  timingSinkNode.getNode(), cryptoSourceNode, timingSinkNode, "Timing attack against $@ validation.",
  cryptoSourceNode.getNode().(ProduceCryptoCall).getResultType(), "message"