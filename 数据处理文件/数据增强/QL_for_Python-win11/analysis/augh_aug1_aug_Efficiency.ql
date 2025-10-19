/**
 * 评估指向关系分析的有效性指标。通过计算"有效分析结果"在"总体分析结果"中的比例，
 * 衡量分析过程的准确性和信息密度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为缺乏分析价值的谓词
predicate isLowValueNode(ControlFlowNode node) {
  // 以下类型的节点被视为低分析价值：函数参数、名称常量或不可变字面量
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的有效性指标
from int valuableFactsCount, int sourceValuableFactsCount, int totalFactsCount, float precisionMetric
where
  // 统计有效分析结果总数（排除低价值节点）
  valuableFactsCount =
    strictcount(ControlFlowNode node, Object refObj, ClassObject tgtClass |
      node.refersTo(refObj, tgtClass, _) and not isLowValueNode(node)
    ) and
  // 统计源文件中的有效分析结果数量
  sourceValuableFactsCount =
    strictcount(ControlFlowNode node, Object refObj, ClassObject tgtClass |
      node.refersTo(refObj, tgtClass, _) and
      not isLowValueNode(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 统计所有指向关系分析结果的总数
  totalFactsCount =
    strictcount(ControlFlowNode node, PointsToContext context, Object refObj, 
      ClassObject tgtClass, ControlFlowNode originalNode | 
      PointsTo::points_to(node, context, refObj, tgtClass, originalNode)
    ) and
  // 计算有效性指标：源文件有效分析结果占总体分析结果的百分比
  precisionMetric = 100.0 * sourceValuableFactsCount / totalFactsCount
select valuableFactsCount, sourceValuableFactsCount, totalFactsCount, precisionMetric