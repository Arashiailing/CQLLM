/**
 * @name Timing attack against Hash
 * @description 在进行哈希验证时，必须采用恒定时间算法进行比较。
 *              如果使用可变时间比较，攻击者可通过精确测量响应时间差异
 *              逐步推断出哈希值，从而可能绕过安全验证机制。
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
 * 时间攻击漏洞检测的数据流配置模块
 * 跟踪从加密哈希生成到不安全时间比较的污点传播
 */
private module TimingVulnerabilityConfig implements DataFlow::ConfigSig {
  // 源定义：识别所有生成加密哈希值的操作调用
  predicate isSource(DataFlow::Node cryptoSourceNode) { 
    cryptoSourceNode instanceof ProduceCryptoCall 
  }

  // 汇定义：识别所有可能暴露时间侧信道的比较操作
  predicate isSink(DataFlow::Node timingVulnerableSink) { 
    timingVulnerableSink instanceof NonConstantTimeComparisonSink 
  }
}

// 基于上述配置创建全局污点跟踪模块，用于分析时间攻击路径
module TimingVulnerabilityFlow = TaintTracking::Global<TimingVulnerabilityConfig>;

import TimingVulnerabilityFlow::PathGraph

// 主查询：检测从加密哈希操作到非恒定时间比较的完整数据流路径
from
  TimingVulnerabilityFlow::PathNode cryptoOriginNode,
  TimingVulnerabilityFlow::PathNode vulnerableComparisonNode
where 
  TimingVulnerabilityFlow::flowPath(cryptoOriginNode, vulnerableComparisonNode)
select vulnerableComparisonNode.getNode(), 
       cryptoOriginNode, 
       vulnerableComparisonNode, 
       "针对$@的哈希验证存在时间攻击风险",
       cryptoOriginNode.getNode().(ProduceCryptoCall).getResultType(), 
       "消息哈希"