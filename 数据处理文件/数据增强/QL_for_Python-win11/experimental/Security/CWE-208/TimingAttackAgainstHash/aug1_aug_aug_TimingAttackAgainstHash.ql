/**
 * @name Timing attack against Hash
 * @description 当验证消息哈希值时，必须使用恒定时间算法。
 *              否则攻击者可通过运行时差异伪造有效哈希值，
 *              导致身份验证机制被绕过。
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
 * 哈希时序攻击分析配置模块
 * 定义数据流分析的源点（加密操作）和汇点（非恒定时间比较）
 */
private module HashTimingAnalysisConfig implements DataFlow::ConfigSig {
  /**
   * 源点定义：加密操作产生的数据节点
   * 包括哈希函数调用等可能产生加密值的操作
   */
  predicate isSource(DataFlow::Node sourceNode) { 
    sourceNode instanceof ProduceCryptoCall 
  }

  /**
   * 汇点定义：非恒定时间比较操作节点
   * 这些操作可能通过执行时间泄露敏感信息
   */
  predicate isSink(DataFlow::Node sinkNode) { 
    sinkNode instanceof NonConstantTimeComparisonSink 
  }
}

/**
 * 全局污点跟踪模块
 * 跟踪从加密操作到非恒定时间比较的数据流路径
 */
module HashTimingAttackFlow = TaintTracking::Global<HashTimingAnalysisConfig>;

// 导入路径图用于路径分析
import HashTimingAttackFlow::PathGraph

/**
 * 主查询：检测哈希验证中的时序攻击路径
 * 查找从加密操作到非恒定时间比较的数据流，
 * 且比较操作涉及用户可控输入
 */
from HashTimingAttackFlow::PathNode sourcePathNode, HashTimingAttackFlow::PathNode sinkPathNode
where
  // 条件1：存在从加密操作到比较操作的数据流路径
  HashTimingAttackFlow::flowPath(sourcePathNode, sinkPathNode) and
  // 条件2：比较操作包含用户输入，扩大攻击面
  sinkPathNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // 输出格式：汇节点、源节点、路径节点、描述信息、消息类型
  sinkPathNode.getNode(), 
  sourcePathNode, 
  sinkPathNode, 
  "Timing attack against $@ validation.",
  sourcePathNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"