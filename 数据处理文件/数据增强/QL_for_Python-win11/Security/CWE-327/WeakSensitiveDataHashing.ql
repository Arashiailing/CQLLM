/**
 * @name Use of a broken or weak cryptographic hashing algorithm on sensitive data
 * @description Using broken or weak cryptographic hashing algorithms can compromise security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/weak-sensitive-data-hashing
 * @tags security
 *       external/cwe/cwe-327
 *       external/cwe/cwe-328
 *       external/cwe/cwe-916
 */

// 导入Python库
import python
// 导入安全数据流分析相关的查询模块
import semmle.python.security.dataflow.WeakSensitiveDataHashingQuery
// 导入数据流分析模块
import semmle.python.dataflow.new.DataFlow
// 导入污点跟踪模块
import semmle.python.dataflow.new.TaintTracking
// 导入路径图类
import WeakSensitiveDataHashingFlow::PathGraph

from
  // 定义源节点和汇节点，类型为PathNode
  WeakSensitiveDataHashingFlow::PathNode source, WeakSensitiveDataHashingFlow::PathNode sink,
  // 定义字符串变量ending，用于存储结果的结尾部分
  string ending, 
  // 定义字符串变量algorithmName，用于存储哈希算法的名称
  string algorithmName, 
  // 定义字符串变量classification，用于存储敏感数据的分类
  string classification
where
  // 检查是否存在正常的哈希函数数据流路径
  normalHashFunctionFlowPath(source, sink) and
  // 获取汇节点的哈希算法名称
  algorithmName = sink.getNode().(NormalHashFunction::Sink).getAlgorithmName() and
  // 获取源节点的数据分类
  classification = source.getNode().(NormalHashFunction::Source).getClassification() and
  // 设置ending为"."
  ending = "."
  or
  // 检查是否存在计算密集型的哈希函数数据流路径
  computationallyExpensiveHashFunctionFlowPath(source, sink) and
  // 获取汇节点的哈希算法名称
  algorithmName = sink.getNode().(ComputationallyExpensiveHashFunction::Sink).getAlgorithmName() and
  // 获取源节点的数据分类
  classification =
    source.getNode().(ComputationallyExpensiveHashFunction::Source).getClassification() and
  (
    // 如果汇节点是计算密集型的哈希函数，设置ending为"."
    sink.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
    ending = "."
    or
    // 如果汇节点不是计算密集型的哈希函数，设置特定的ending信息
    not sink.getNode().(ComputationallyExpensiveHashFunction::Sink).isComputationallyExpensive() and
    ending =
      " for " + classification +
        " hashing, since it is not a computationally expensive hash function."
  )
select 
  // 选择汇节点、源节点、汇节点、警告信息和敏感数据分类作为查询结果
  sink.getNode(), source, sink,
  "$@ is used in a hashing algorithm (" + algorithmName + ") that is insecure" + ending,
  source.getNode(), "Sensitive data (" + classification + ")"
