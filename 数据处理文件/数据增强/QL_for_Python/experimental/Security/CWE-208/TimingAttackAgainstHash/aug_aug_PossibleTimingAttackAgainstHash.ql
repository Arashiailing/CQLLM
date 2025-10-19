/**
 * @name Timing attack against Hash
 * @description 在验证消息哈希值时，必须使用恒定时间算法。
 *              如果使用非恒定时间比较，攻击者可以通过测量响应时间
 *              来推断哈希值，从而可能绕过身份验证机制。
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
 * 数据流配置：定义从加密操作到非恒定时间比较的污点传播路径
 */
private module CryptoTimingFlowConfig implements DataFlow::ConfigSig {
  // 源定义：识别所有产生加密值的操作调用
  predicate isSource(DataFlow::Node cryptographicOperation) { 
    cryptographicOperation instanceof ProduceCryptoCall 
  }

  // 汇定义：识别所有可能存在时间侧信道的比较操作
  predicate isSink(DataFlow::Node timeVulnerableComparison) { 
    timeVulnerableComparison instanceof NonConstantTimeComparisonSink 
  }
}

// 创建全局污点跟踪模块，用于分析加密值到不安全比较的数据流
module CryptoTimingFlow = TaintTracking::Global<CryptoTimingFlowConfig>;

import CryptoTimingFlow::PathGraph

// 主查询：查找从加密操作到非恒定时间比较的完整数据流路径
from
  CryptoTimingFlow::PathNode sourceNode,
  CryptoTimingFlow::PathNode sinkNode
where CryptoTimingFlow::flowPath(sourceNode, sinkNode)
select sinkNode.getNode(), 
       sourceNode, 
       sinkNode, 
       "针对$@验证存在时间攻击风险",
       sourceNode.getNode().(ProduceCryptoCall).getResultType(), 
       "消息哈希"