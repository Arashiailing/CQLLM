/**
 * @name Timing attack against secret
 * @description Use of a non-constant-time verification routine to check the value of an secret,
 *              possibly allowing a timing attack to retrieve sensitive information.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @id py/possible-timing-attack-sensitive-info
 * @tags security
 *       external/cwe/cwe-208
 *       experimental
 */

// 导入Python语言库
import python
// 导入数据流分析模块
import semmle.python.dataflow.new.DataFlow
// 导入污点跟踪模块
import semmle.python.dataflow.new.TaintTracking
// 导入实验性安全分析模块中的TimingAttack子模块
import experimental.semmle.python.security.TimingAttack

/**
 * A configuration tracing flow from obtaining a client Secret to a unsafe Comparison.
 * 配置从获取客户端秘密到不安全的比较的流动路径。
 */
private module PossibleTimingAttackAgainstSensitiveInfoConfig implements DataFlow::ConfigSig {
  // 定义源节点谓词，判断节点是否为SecretSource类型
  predicate isSource(DataFlow::Node source) { source instanceof SecretSource }

  // 定义汇节点谓词，判断节点是否为NonConstantTimeComparisonSink类型
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }

  // 定义观察差异的增量模式，这里使用any()表示任意情况都适用
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 定义一个全局污点跟踪流，用于检测可能的时间攻击路径
module PossibleTimingAttackAgainstSensitiveInfoFlow =
  TaintTracking::Global<PossibleTimingAttackAgainstSensitiveInfoConfig>;

// 导入路径图模块，用于后续查询
import PossibleTimingAttackAgainstSensitiveInfoFlow::PathGraph

// 查询语句，查找从源节点到汇节点的流动路径
from
  PossibleTimingAttackAgainstSensitiveInfoFlow::PathNode source, // 源节点
  PossibleTimingAttackAgainstSensitiveInfoFlow::PathNode sink    // 汇节点
where PossibleTimingAttackAgainstSensitiveInfoFlow::flowPath(source, sink) // 条件：存在从源到汇的流动路径
select sink.getNode(), source, sink, "Timing attack against $@ validation.", source.getNode(),
  "client-supplied token" // 选择结果，包括汇节点、源节点、路径信息以及描述信息
