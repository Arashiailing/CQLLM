/**
 * @name Timing attack against Hash
 * @description 检测哈希验证过程中的时序攻击漏洞。
 *              当使用非恒定时间算法验证哈希值时，攻击者可利用响应时间差异
 *              推断有效哈希，从而绕过安全验证机制。
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
 * 时序攻击分析配置与流跟踪模块
 * 配置数据流分析的源点（加密操作）和汇点（非恒定时间比较），
 * 并建立全局污点跟踪模型
 */
private module CryptoTimingAnalysisConfig implements DataFlow::ConfigSig {
  /**
   * 源点识别：标记加密操作产生的数据节点
   * 涵盖哈希函数调用等生成加密值的操作
   */
  predicate isSource(DataFlow::Node cryptoSource) { 
    cryptoSource instanceof ProduceCryptoCall 
  }

  /**
   * 汇点识别：标记非恒定时间比较操作节点
   * 这些操作可能因执行时间差异泄露敏感信息
   */
  predicate isSink(DataFlow::Node vulnerableSink) { 
    vulnerableSink instanceof NonConstantTimeComparisonSink 
  }
}

/**
 * 加密时序攻击污点流跟踪模块
 * 追踪从加密操作到非恒定时间比较的完整数据流路径
 */
module CryptoTimingFlow = TaintTracking::Global<CryptoTimingAnalysisConfig>;

// 导入路径图用于可视化分析数据流路径
import CryptoTimingFlow::PathGraph

/**
 * 主查询：识别哈希验证中的时序攻击风险路径
 * 定位从加密操作到非恒定时间比较的数据流，
 * 特别关注涉及用户可控输入的比较操作
 */
from CryptoTimingFlow::PathNode originPathNode, CryptoTimingFlow::PathNode targetPathNode
where
  // 确保存在从加密源到脆弱汇点的数据流路径
  CryptoTimingFlow::flowPath(originPathNode, targetPathNode) and
  // 验证比较操作包含用户输入，增加攻击可能性
  targetPathNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // 输出格式：目标节点、源节点、路径节点、描述信息、消息类型
  targetPathNode.getNode(), 
  originPathNode, 
  targetPathNode, 
  "Timing attack against $@ validation.",
  originPathNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"