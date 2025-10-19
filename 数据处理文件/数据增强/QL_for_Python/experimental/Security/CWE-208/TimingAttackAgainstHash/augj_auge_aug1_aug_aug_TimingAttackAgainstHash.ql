/**
 * @name Timing attack against Hash
 * @description 在验证消息哈希值时，必须采用恒定时间算法。
 *              若不使用恒定时间算法，攻击者可能利用执行时间差异
 *              来伪造有效的哈希值，从而绕过身份验证机制。
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
 * 哈希时序攻击分析配置
 * 定义数据流分析的源点（加密操作）和汇点（非恒定时间比较）
 */
private module HashTimingAttackConfig implements DataFlow::ConfigSig {
  /**
   * 源点定义：加密操作产生的数据节点
   * 包括哈希函数调用等生成加密值的操作
   */
  predicate isSource(DataFlow::Node cryptoOrigin) { 
    cryptoOrigin instanceof ProduceCryptoCall 
  }

  /**
   * 汇点定义：非恒定时间比较操作节点
   * 这些操作可能因执行时间差异泄露敏感信息
   */
  predicate isSink(DataFlow::Node timingVulnerableSink) { 
    timingVulnerableSink instanceof NonConstantTimeComparisonSink 
  }
}

/**
 * 全局污点传播跟踪模块
 * 追踪从加密操作到非恒定时间比较的数据流传播路径
 */
module HashTimingAttackFlow = TaintTracking::Global<HashTimingAttackConfig>;

// 导入路径图用于路径分析
import HashTimingAttackFlow::PathGraph

/**
 * 核心查询：识别哈希验证中的时序攻击风险路径
 * 检测从加密操作到非恒定时间比较的数据流，
 * 且该比较操作涉及用户可控制的输入
 */
from HashTimingAttackFlow::PathNode sourcePath, HashTimingAttackFlow::PathNode sinkPath
where
  // 条件1：存在从加密操作到比较操作的数据流路径
  HashTimingAttackFlow::flowPath(sourcePath, sinkPath) and
  // 条件2：比较操作包含用户输入，增加攻击可能性
  sinkPath.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // 输出格式：汇点节点、源点节点、路径节点、描述信息、消息类型
  sinkPath.getNode(), 
  sourcePath, 
  sinkPath, 
  "Timing attack against $@ validation.",
  sourcePath.getNode().(ProduceCryptoCall).getResultType(), 
  "message"