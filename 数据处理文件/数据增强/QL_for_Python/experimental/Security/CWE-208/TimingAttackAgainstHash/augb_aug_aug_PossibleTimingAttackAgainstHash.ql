/**
 * @name Timing attack against Hash
 * @description 消息哈希验证过程应采用恒定时间算法实现。
 *              非恒定时间比较可能使攻击者通过响应时间差异推断哈希值，
 *              从而导致身份验证机制被绕过。
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
 * 污点传播配置：追踪加密值流向非恒定时间比较操作的数据流
 */
private module HashTimingAnalysisConfig implements DataFlow::ConfigSig {
  // 源谓词：标识生成加密值的操作调用
  predicate isSource(DataFlow::Node cryptoOperation) { 
    cryptoOperation instanceof ProduceCryptoCall 
  }

  // 汇谓词：标识易受时间攻击的比较操作
  predicate isSink(DataFlow::Node vulnerableComparison) { 
    vulnerableComparison instanceof NonConstantTimeComparisonSink 
  }
}

// 构建全局污点传播分析模块，用于检测加密值到不安全比较的数据流
module HashTimingAnalysis = TaintTracking::Global<HashTimingAnalysisConfig>;

import HashTimingAnalysis::PathGraph

// 主查询：识别从加密操作到非恒定时间比较的完整数据流路径
from
  HashTimingAnalysis::PathNode originNode,
  HashTimingAnalysis::PathNode targetNode
where 
  HashTimingAnalysis::flowPath(originNode, targetNode)
select 
  targetNode.getNode(), 
  originNode, 
  targetNode, 
  "检测到针对$@验证的时间攻击风险",
  originNode.getNode().(ProduceCryptoCall).getResultType(), 
  "消息哈希"