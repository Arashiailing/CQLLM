/**
 * 评估指向关系分析的效率指标。计算"非平凡事实"与"总事实"的比率，
 * 以衡量分析结果的有效性和信息密度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为平凡（无分析价值）的谓词
predicate isTrivialNode(ControlFlowNode node) {
  // 节点属于以下情况时视为平凡：函数参数、名称常量或不可变字面量
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算并选择指向关系分析的效率指标
from int nonTrivialFactsCount, int sourceNonTrivialFactsCount, int totalFactsCount, float efficiencyRatio
where
  // 统计非平凡事实总数（排除无分析价值的节点）
  nonTrivialFactsCount =
    strictcount(ControlFlowNode node, Object pointedObject, ClassObject objectClass |
      node.refersTo(pointedObject, objectClass, _) and not isTrivialNode(node)
    ) and
  // 统计源文件中的非平凡事实数量
  sourceNonTrivialFactsCount =
    strictcount(ControlFlowNode node, Object pointedObject, ClassObject objectClass |
      node.refersTo(pointedObject, objectClass, _) and
      not isTrivialNode(node) and
      exists(node.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 统计所有指向关系事实的总数
  totalFactsCount =
    strictcount(ControlFlowNode node, PointsToContext context, Object pointedObject, 
      ClassObject objectClass, ControlFlowNode originalNode | 
      PointsTo::points_to(node, context, pointedObject, objectClass, originalNode)
    ) and
  // 计算效率比率：源文件非平凡事实占总事实的百分比
  efficiencyRatio = 100.0 * sourceNonTrivialFactsCount / totalFactsCount
select nonTrivialFactsCount, sourceNonTrivialFactsCount, totalFactsCount, efficiencyRatio