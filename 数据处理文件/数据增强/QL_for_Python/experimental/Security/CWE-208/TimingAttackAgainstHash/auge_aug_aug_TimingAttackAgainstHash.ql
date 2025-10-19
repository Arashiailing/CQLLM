/**
 * @name Timing attack against Hash
 * @description 检测哈希值验证中的时序攻击漏洞。当验证消息哈希时，
 *              必须使用恒定时间算法，否则攻击者可能通过响应时间差异
 *              猜测有效哈希值，导致身份验证被绕过。
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
 * 时序攻击分析配置：定义数据流源和汇点
 * 用于追踪从加密操作到非恒定时间比较的数据流
 */
private module HashTimingConfig implements DataFlow::ConfigSig {
  /**
   * 数据流源：产生加密值的操作节点
   * 包括哈希函数调用等可能产生加密值的操作
   */
  predicate isSource(DataFlow::Node hashOpNode) { 
    hashOpNode instanceof ProduceCryptoCall 
  }

  /**
   * 数据流汇：非恒定时间比较操作节点
   * 这些比较操作可能泄露时序信息，成为攻击向量
   */
  predicate isSink(DataFlow::Node vulnerableCompareNode) { 
    vulnerableCompareNode instanceof NonConstantTimeComparisonSink 
  }
}

/**
 * 全局污点跟踪模块，用于追踪加密值到非恒定时间比较的数据流
 */
module HashTimingFlow = TaintTracking::Global<HashTimingConfig>;

// 导入路径图用于分析完整的数据流路径
import HashTimingFlow::PathGraph

/**
 * 主查询：识别潜在的时序攻击路径
 * 检测从加密操作到非恒定时间比较的数据流，
 * 特别关注涉及用户输入的比较操作
 */
from HashTimingFlow::PathNode sourceNode, HashTimingFlow::PathNode sinkNode
where
  // 确保存在从加密操作到非恒定时间比较的数据流路径
  HashTimingFlow::flowPath(sourceNode, sinkNode) and
  // 筛选包含用户输入的比较操作，增加攻击可能性
  sinkNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // 输出格式：汇节点、源节点、路径节点、描述信息、消息类型
  sinkNode.getNode(), sourceNode, sinkNode, "Timing attack against $@ validation.",
  sourceNode.getNode().(ProduceCryptoCall).getResultType(), "message"