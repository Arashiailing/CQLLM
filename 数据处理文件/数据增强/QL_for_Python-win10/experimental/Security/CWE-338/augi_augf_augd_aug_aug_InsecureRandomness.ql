/**
 * @name Insecure randomness
 * @description Detects utilization of cryptographically weak pseudo-random number generators
 *              within security-sensitive operations, potentially allowing adversaries to forecast
 *              generated values and undermine system security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/insecure-randomness
 * @tags security
 *       experimental
 *       external/cwe/cwe-338
 */

// 导入Python核心分析库，提供基础代码分析能力
import python

// 导入实验性安全模块，专门用于识别弱随机数生成模式
import experimental.semmle.python.security.InsecureRandomness

// 导入数据流分析框架，用于追踪值在代码中的传播路径
import semmle.python.dataflow.new.DataFlow

// 导入路径图模块，支持数据流路径的可视化展示
import InsecureRandomness::Flow::PathGraph

// 查询定义：识别从弱随机源到安全敏感上下文的数据流路径
from 
  InsecureRandomness::Flow::PathNode insecureRandomSource,    // 弱随机值的生成起点
  InsecureRandomness::Flow::PathNode sensitiveContextSink     // 安全敏感的使用点
where 
  // 验证弱随机源到敏感上下文之间存在完整数据流路径
  InsecureRandomness::Flow::flowPath(insecureRandomSource, sensitiveContextSink)
select 
  sensitiveContextSink.getNode(),                      // 不安全值的目标使用位置
  insecureRandomSource,                                // 路径可视化起点
  sensitiveContextSink,                                // 路径可视化终点
  "Cryptographically insecure $@ in security context.", // 告警消息模板
  insecureRandomSource.getNode(),                      // 消息上下文引用节点
  "random value"                                       // 漏洞元素描述