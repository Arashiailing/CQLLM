/**
 * 评估指向关系分析的有效性指标。计算"有效分析结果"在"总分析结果"中的比例，
 * 用于衡量分析过程的精确度和信息密度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为无分析价值的谓词
predicate isTrivialNode(ControlFlowNode node) {
  // 节点属于以下情况时视为无分析价值：函数参数、名称常量或不可变字面量
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算并选择指向关系分析的质量指标
from int significantFactsCount, int sourceSignificantFactsCount, int totalFactsCount, float precisionScore
where
  // 统计有意义的分析结果总数（排除无分析价值的节点）
  significantFactsCount =
    strictcount(ControlFlowNode node, Object refObj, ClassObject cls |
      node.refersTo(refObj, cls, _) and not isTrivialNode(node)
    ) and
  // 统计源文件中的有意义分析结果数量
  sourceSignificantFactsCount =
    strictcount(ControlFlowNode node, Object refObj, ClassObject cls |
      node.refersTo(refObj, cls, _) and
      not isTrivialNode(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 统计所有指向关系分析结果的总数
  totalFactsCount =
    strictcount(ControlFlowNode node, PointsToContext context, Object refObj, 
      ClassObject cls, ControlFlowNode originalNode | 
      PointsTo::points_to(node, context, refObj, cls, originalNode)
    ) and
  // 计算质量指标：源文件有意义分析结果占全部分析结果的百分比
  precisionScore = 100.0 * sourceSignificantFactsCount / totalFactsCount
select significantFactsCount, sourceSignificantFactsCount, totalFactsCount, precisionScore