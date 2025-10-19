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

// 导入Python核心库，用于支持Python代码分析
import python

// 导入实验性安全模块，专用于检测不安全的随机数生成模式
import experimental.semmle.python.security.InsecureRandomness

// 导入数据流分析框架，支持数据流路径追踪
import semmle.python.dataflow.new.DataFlow

// 导入路径图模块，用于表示数据流路径图
import InsecureRandomness::Flow::PathGraph

// 查询定义：识别不安全随机数生成的数据流路径问题
from InsecureRandomness::Flow::PathNode originNode, InsecureRandomness::Flow::PathNode targetNode
where InsecureRandomness::Flow::flowPath(originNode, targetNode) // 条件：存在从源节点到目标节点的数据流路径
select targetNode.getNode(), originNode, targetNode, "Cryptographically insecure $@ in a security context.",
  originNode.getNode(), "random value" // 选择结果：目标节点、源节点、路径信息和描述信息