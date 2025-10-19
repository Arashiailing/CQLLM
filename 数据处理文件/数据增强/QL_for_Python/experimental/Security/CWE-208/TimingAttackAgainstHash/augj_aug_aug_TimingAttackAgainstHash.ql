/**
 * @name Timing attack against Hash
 * @description 当验证消息哈希值时，必须使用恒定时间算法。
 *              否则攻击者可通过运行时差异伪造有效哈希值，
 *              导致身份验证绕过。
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
 * 加密时序分析配置模块
 * 跟踪从加密操作到非恒定时间比较的数据流
 */
private module CryptoTimingConfig implements DataFlow::ConfigSig {
  /** 数据流源：加密调用产生的节点 */
  predicate isSource(DataFlow::Node cryptoNode) { 
    cryptoNode instanceof ProduceCryptoCall 
  }

  /** 数据流汇：非恒定时间比较操作节点 */
  predicate isSink(DataFlow::Node vulnerableComparisonNode) { 
    vulnerableComparisonNode instanceof NonConstantTimeComparisonSink 
  }
}

/** 基于配置的全局污点跟踪模块 */
module CryptoTimingFlow = TaintTracking::Global<CryptoTimingConfig>;

// 导入路径图用于路径分析
import CryptoTimingFlow::PathGraph

/**
 * 主查询：检测加密时序攻击路径
 * 查找从加密操作到非恒定时间比较的数据流路径，
 * 且比较操作包含用户输入的情况
 */
from CryptoTimingFlow::PathNode sourceNode, CryptoTimingFlow::PathNode sinkNode
where
  // 存在从加密操作到比较操作的数据流路径
  CryptoTimingFlow::flowPath(sourceNode, sinkNode)
  and
  // 比较操作包含用户输入，扩大攻击面
  sinkNode.getNode().(NonConstantTimeComparisonSink).includesUserInput()
select 
  // 输出格式：汇节点、源节点、路径节点、描述信息、消息类型
  sinkNode.getNode(), sourceNode, sinkNode, "Timing attack against $@ validation.",
  sourceNode.getNode().(ProduceCryptoCall).getResultType(), "message"