/**
 * 指向分析效果量化工具。此查询用于度量指向分析的精确度和信息密度，
 * 通过计算有效分析结果在总体分析结果中的占比来评估分析质量。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 标记控制流图中缺乏分析价值的节点
predicate isTrivialNode(ControlFlowNode node) {
  // 以下节点类型被认为是无分析价值的：函数参数、名称常量或不可变字面量
  node.getNode() instanceof Parameter
  or
  node instanceof NameConstantNode
  or
  node.getNode() instanceof ImmutableLiteral
}

// 计算指向分析的效能指标
from int meaningfulFactsCount, int sourceMeaningfulFactsCount, int allFactsCount, float analysisEfficiency
where
  // 统计有效分析结果的数量
  meaningfulFactsCount = strictcount(ControlFlowNode flowNode, Object pointedObject, ClassObject destinationClass |
    flowNode.refersTo(pointedObject, destinationClass, _) and not isTrivialNode(flowNode)
  ) and
  // 统计源代码文件中的有效分析结果数量
  sourceMeaningfulFactsCount = strictcount(ControlFlowNode flowNode, Object pointedObject, ClassObject destinationClass |
    flowNode.refersTo(pointedObject, destinationClass, _) and
    not isTrivialNode(flowNode) and
    exists(flowNode.getScope().getEnclosingModule().getFile().getRelativePath())
  ) and
  // 计算全部指向关系事实的总数
  allFactsCount = strictcount(ControlFlowNode flowNode, PointsToContext pointingContext, Object pointedObject, 
    ClassObject destinationClass, ControlFlowNode originNode | 
    PointsTo::points_to(flowNode, pointingContext, pointedObject, destinationClass, originNode)
  ) and
  // 计算分析效能：源文件中有效事实占全部事实的百分比
  analysisEfficiency = 100.0 * sourceMeaningfulFactsCount / allFactsCount
select meaningfulFactsCount, sourceMeaningfulFactsCount, allFactsCount, analysisEfficiency