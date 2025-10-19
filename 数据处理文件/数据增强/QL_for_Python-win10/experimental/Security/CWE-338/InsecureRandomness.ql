/**
 * @name Insecure randomness
 * @description Using a cryptographically weak pseudo-random number generator to generate a
 *              security-sensitive value may allow an attacker to predict what value will
 *              be generated.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// 导入Python库，用于分析Python代码
import python

// 导入实验性的semmle.python.security.InsecureRandomness模块，用于检测不安全的随机数生成
import experimental.semmle.python.security.InsecureRandomness

// 导入数据流分析模块，用于跟踪数据流路径
import semmle.python.dataflow.new.DataFlow

// 从InsecureRandomness::Flow::PathGraph中导入路径图，用于表示数据流路径
import InsecureRandomness::Flow::PathGraph

// 定义查询语句，查找不安全随机数生成的路径问题
from InsecureRandomness::Flow::PathNode source, InsecureRandomness::Flow::PathNode sink
where InsecureRandomness::Flow::flowPath(source, sink) // 条件：存在从源节点到汇节点的数据流路径
select sink.getNode(), source, sink, "Cryptographically insecure $@ in a security context.",
  source.getNode(), "random value" // 选择结果：汇节点、源节点、路径信息和描述信息
