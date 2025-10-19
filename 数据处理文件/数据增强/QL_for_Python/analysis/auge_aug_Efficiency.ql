/**
 * 指向关系分析效率评估器。本查询计算"有意义事实"与"全部事实"的比率，
 * 用于量化指向分析的有效性和信息密度，评估分析结果的质量。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 识别控制流图中不包含有价值分析信息的节点
predicate isTrivialNode(ControlFlowNode node) {
  // 以下类型的节点被视为平凡：函数参数、名称常量或不可变字面量
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的效率指标
from int meaningfulFactsCount, int sourceMeaningfulFactsCount, int allFactsCount, float analysisEfficiency
where
  // 计算非平凡事实的总数量（过滤掉无分析价值的节点）
  meaningfulFactsCount =
    strictcount(ControlFlowNode cfgNode, Object referencedObject, ClassObject targetClass |
      cfgNode.refersTo(referencedObject, targetClass, _) and not isTrivialNode(cfgNode)
    ) and
  // 计算源代码文件中的非平凡事实数量
  sourceMeaningfulFactsCount =
    strictcount(ControlFlowNode cfgNode, Object referencedObject, ClassObject targetClass |
      cfgNode.refersTo(referencedObject, targetClass, _) and
      not isTrivialNode(cfgNode) and
      exists(cfgNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 统计所有指向关系事实的总数
  allFactsCount =
    strictcount(ControlFlowNode cfgNode, PointsToContext context, Object referencedObject, 
      ClassObject targetClass, ControlFlowNode originalNode | 
      PointsTo::points_to(cfgNode, context, referencedObject, targetClass, originalNode)
    ) and
  // 计算分析效率：源文件中有意义事实占全部事实的百分比
  analysisEfficiency = 100.0 * sourceMeaningfulFactsCount / allFactsCount
select meaningfulFactsCount, sourceMeaningfulFactsCount, allFactsCount, analysisEfficiency