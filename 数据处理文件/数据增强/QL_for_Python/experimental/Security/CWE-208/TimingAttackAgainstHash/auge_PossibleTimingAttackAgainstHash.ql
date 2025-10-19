/**
 * @name Timing attack against Hash
 * @description 当验证消息哈希值时，必须使用恒定时间算法。
 *              否则攻击者可通过响应时间差异伪造有效哈希值，
 *              成功攻击可能导致身份验证机制被绕过。
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
 * 配置模块：跟踪从加密操作到非恒定时间比较的数据流
 */
private module TimingAttackHashConfig implements DataFlow::ConfigSig {
  // 源节点定义：加密操作调用
  predicate isSource(DataFlow::Node cryptoOp) { 
    cryptoOp instanceof ProduceCryptoCall 
  }

  // 汇节点定义：非恒定时间比较操作
  predicate isSink(DataFlow::Node comparison) { 
    comparison instanceof NonConstantTimeComparisonSink 
  }
}

// 全局污点跟踪模块，基于上述配置
module TimingAttackHashFlow = TaintTracking::Global<TimingAttackHashConfig>;

import TimingAttackHashFlow::PathGraph

// 查询主逻辑：检测从加密操作到非恒定时间比较的数据流路径
from
  TimingAttackHashFlow::PathNode srcNode,
  TimingAttackHashFlow::PathNode sinkNode
where 
  TimingAttackHashFlow::flowPath(srcNode, sinkNode)
select 
  sinkNode.getNode(), 
  srcNode, 
  sinkNode, 
  "可能存在针对$@验证的时间攻击。",
  srcNode.getNode().(ProduceCryptoCall).getResultType(), 
  "message"