/**
 * @name 多项式复杂度正则表达式应用于未受控数据
 * @description 具有多项式时间复杂度的正则表达式匹配可能面临
 *              拒绝服务攻击风险
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/polynomial-redos
 * @tags security
 *       external/cwe/cwe-1333
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */

// 导入Python核心库
import python
// 导入多项式ReDoS查询模块
import semmle.python.security.dataflow.PolynomialReDoSQuery
// 导入路径图分析模块
import PolynomialReDoSFlow::PathGraph

// 定义核心分析元素
from
  // 数据流路径的源节点和汇节点
  PolynomialReDoSFlow::PathNode sourceNode, PolynomialReDoSFlow::PathNode sinkPathNode,
  // 汇点对应的Sink实例
  Sink sinkInstance,
  // 危险的正则表达式回溯项
  PolynomialBackTrackingTerm vulnerableRegex
where
  // 验证存在数据流路径
  PolynomialReDoSFlow::flowPath(sourceNode, sinkPathNode) and
  // 关联路径节点与Sink实例
  sinkInstance = sinkPathNode.getNode() and
  // 提取危险正则表达式
  vulnerableRegex = sinkInstance.getABacktrackingTerm()
// 注释掉的过滤条件：非URL源且行尾匹配
//   not (
//     sourceNode.getNode().(Source).getKind() = "url" and
//     vulnerableRegex.isAtEndLine()
//   )
select 
  // 高亮显示的汇点位置
  sinkInstance.getHighlight(), sourceNode, sinkPathNode,
  // 构造风险描述消息
  "此 $@ 依赖的 $@ 在处理包含大量 '" + vulnerableRegex.getPumpString() + 
  "' 重复的字符串时可能性能低下" + vulnerableRegex.getPrefixMessage() + ".",
  // 正则表达式相关描述
  vulnerableRegex, "正则表达式",
  // 用户输入源描述
  sourceNode.getNode(), "用户输入值"