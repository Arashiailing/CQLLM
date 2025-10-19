/**
 * 指向关系分析效能评估查询。本查询通过计算"有意义事实"与"总体事实"的比率，
 * 来量化评估指向分析结果的精确度和信息密度，为分析质量提供度量标准。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

/**
 * 判断控制流节点是否为无分析价值的平凡节点。
 * 平凡节点包括：函数参数、名称常量或不可变字面量，
 * 这些节点通常不包含有价值的程序行为信息。
 */
predicate isInsignificantNode(ControlFlowNode controlNode) {
  // 以下类型的节点被视为无分析价值
  controlNode.getNode() instanceof Parameter
  or
  controlNode instanceof NameConstantNode
  or
  controlNode.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的效能指标
from int meaningfulFactsCount, int sourceMeaningfulFactsCount, int overallFactsCount, float effectivenessMetric
where
  // 计算所有非平凡（有意义）的指向关系事实总数
  meaningfulFactsCount =
    strictcount(ControlFlowNode controlNode, Object targetObject, ClassObject targetClass |
      controlNode.refersTo(targetObject, targetClass, _) and not isInsignificantNode(controlNode)
    ) and
  
  // 计算源文件中非平凡指向关系事实的数量
  sourceMeaningfulFactsCount =
    strictcount(ControlFlowNode controlNode, Object targetObject, ClassObject targetClass |
      controlNode.refersTo(targetObject, targetClass, _) and
      not isInsignificantNode(controlNode) and
      exists(controlNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  
  // 计算所有指向关系事实的总体数量
  overallFactsCount =
    strictcount(ControlFlowNode controlNode, PointsToContext analysisContext, Object targetObject, 
      ClassObject targetClass, ControlFlowNode originNode | 
      PointsTo::points_to(controlNode, analysisContext, targetObject, targetClass, originNode)
    ) and
  
  // 计算效能指标：源文件中有意义事实占总体事实的百分比
  effectivenessMetric = 100.0 * sourceMeaningfulFactsCount / overallFactsCount
select meaningfulFactsCount, sourceMeaningfulFactsCount, overallFactsCount, effectivenessMetric