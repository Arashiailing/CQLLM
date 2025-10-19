/**
 * @name Timing attack against Hash
 * @description 验证消息哈希值时必须使用恒定时间算法。
 *              非恒定时间比较会通过运行时差异泄露信息，
 *              使攻击者能够伪造有效哈希并绕过认证机制。
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
 * 加密时序攻击分析配置
 * 指定数据流分析的起点（加密操作）和终点（非恒定时间比较）
 */
private module CryptoTimingAnalysisConfig implements DataFlow::ConfigSig {
  /**
   * 源点定义：识别加密操作产生的数据节点
   * 包括可能生成加密值的哈希函数调用等操作
   */
  predicate isSource(DataFlow::Node cryptoSource) { 
    cryptoSource instanceof ProduceCryptoCall 
  }

  /**
   * 汇点定义：识别非恒定时间比较操作节点
   * 这些操作可能因执行时间差异泄露敏感信息
   */
  predicate isSink(DataFlow::Node timingSink) { 
    timingSink instanceof NonConstantTimeComparisonSink 
  }
}

/**
 * 全局污点传播跟踪模块
 * 追踪从加密操作到非恒定时间比较的数据流路径
 */
module CryptoTimingAttackFlow = TaintTracking::Global<CryptoTimingAnalysisConfig>;

// 导入路径图用于路径分析
import CryptoTimingAttackFlow::PathGraph

/**
 * 主查询：识别哈希验证中的时序攻击路径
 * 定位从加密操作到非恒定时间比较的数据流，
 * 特别关注涉及用户可控输入的比较操作
 */
from CryptoTimingAttackFlow::PathNode cryptoOriginPath, CryptoTimingAttackFlow::PathNode timingTargetPath
where
  // 确保存在从加密操作到比较操作的数据流路径
  CryptoTimingAttackFlow::flowPath(cryptoOriginPath, timingTargetPath) and
  // 检查比较操作是否包含用户输入，评估潜在攻击面
  timingTargetPath.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // 输出格式：汇节点、源节点、路径节点、描述信息、消息类型
  timingTargetPath.getNode(), 
  cryptoOriginPath, 
  timingTargetPath, 
  "Timing attack against $@ validation.",
  cryptoOriginPath.getNode().(ProduceCryptoCall).getResultType(), 
  "message"