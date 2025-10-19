/**
 * @name Timing attack against Hash
 * @description 检测哈希值验证过程中的时间攻击漏洞。
 *              当验证消息哈希值时，必须使用恒定时间算法。
 *              攻击者可能通过分析响应时间的微小差异来推断有效哈希值，
 *              从而绕过身份验证机制。
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
 * 时间攻击数据流配置模块
 * 定义了从加密操作源到非恒定时间比较汇的数据流追踪规则
 */
private module CryptoComparisonConfig implements DataFlow::ConfigSig {
  /**
   * 定义数据流源：加密操作调用
   * 包括哈希生成等加密函数调用
   */
  predicate isSource(DataFlow::Node encryptionCall) { 
    encryptionCall instanceof ProduceCryptoCall 
  }

  /**
   * 定义数据流汇：非恒定时间比较操作
   * 这些比较操作可能会泄露时间信息
   */
  predicate isSink(DataFlow::Node vulnerableComparison) { 
    vulnerableComparison instanceof NonConstantTimeComparisonSink 
  }
}

// 应用上述配置创建全局污点跟踪模块
module HashTimingAttackFlow = TaintTracking::Global<CryptoComparisonConfig>;
import HashTimingAttackFlow::PathGraph

/**
 * 主查询：检测从加密操作到非恒定时间比较的数据流路径
 * 识别可能被时间攻击利用的代码路径
 */
from 
  HashTimingAttackFlow::PathNode cryptoSource,    // 加密操作源节点
  HashTimingAttackFlow::PathNode timingSink       // 非恒定时间比较汇节点
where 
  HashTimingAttackFlow::flowPath(cryptoSource, timingSink)
select 
  timingSink.getNode(), 
  cryptoSource, 
  timingSink, 
  "针对$@验证的时间攻击风险",
  cryptoSource.getNode().(ProduceCryptoCall).getResultType(), 
  "message"