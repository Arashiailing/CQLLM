import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

/**
 * 配置一个安全数据流跟踪，用于检测针对客户端提供的敏感信息的计时攻击。
 * 此配置定义了数据流的源（秘密源）和汇（非常量时间比较汇）。
 */
private module TimingAttackAgainstSensitiveInfoConfig implements DataFlow::ConfigSig {
  // 定义源节点的谓词，判断节点是否为SecretSource类型
  predicate isSource(DataFlow::Node source) { source instanceof SecretSource }

  // 定义汇节点的谓词，判断节点是否为NonConstantTimeComparisonSink类型
  predicate isSink(DataFlow::Node sink) { sink instanceof NonConstantTimeComparisonSink }

  // 定义增量模式下观察差异的谓词，这里使用any()表示任何情况都满足
  predicate observeDiffInformedIncrementalMode() { any() }
}

// 定义一个全局污点跟踪模块，用于追踪从获取客户端秘密到不安全比较的流动路径
module TimingAttackAgainstSensitiveInfoFlow = TaintTracking::Global<TimingAttackAgainstSensitiveInfoConfig>;

/**
 * 检测针对客户端提供的敏感信息的计时攻击。
 * 此查询查找从源节点（秘密源）到汇节点（不安全比较）的流动路径，并检查是否涉及用户输入。
 */
query predicate problems = TimingAttackAgainstSensitiveInfoFlow::flowPath/2;