/**
 * 计算指向关系分析的有效性度量。该指标通过分析"有效分析结果"在"总体分析结果"中的占比，
 * 评估分析过程的精确度和信息密度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 识别控制流节点是否为低分析价值的谓词
predicate isLowValueNode(ControlFlowNode cfgNode) {
  // 以下节点类型被认为具有较低的分析价值：函数参数、名称常量或不可变字面量
  cfgNode.getNode() instanceof Parameter
  or
  cfgNode instanceof NameConstantNode
  or
  cfgNode.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的有效性指标
from int effectiveAnalysisCount, int sourceEffectiveAnalysisCount, int totalAnalysisCount, float effectivenessMetric
where
  // 计算有效分析结果总数（排除低价值节点）
  effectiveAnalysisCount =
    strictcount(ControlFlowNode cfgNode, Object referencedObject, ClassObject targetClass |
      cfgNode.refersTo(referencedObject, targetClass, _) and not isLowValueNode(cfgNode)
    ) and
  // 计算源文件中的有效分析结果数量
  sourceEffectiveAnalysisCount =
    strictcount(ControlFlowNode cfgNode, Object referencedObject, ClassObject targetClass |
      cfgNode.refersTo(referencedObject, targetClass, _) and
      not isLowValueNode(cfgNode) and
      exists(cfgNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  totalAnalysisCount =
    strictcount(ControlFlowNode cfgNode, PointsToContext ptContext, Object referencedObject, 
      ClassObject targetClass, ControlFlowNode originalCfgNode | 
      PointsTo::points_to(cfgNode, ptContext, referencedObject, targetClass, originalCfgNode)
    ) and
  // 计算有效性指标：源文件有效分析结果占总体分析结果的百分比
  effectivenessMetric = 100.0 * sourceEffectiveAnalysisCount / totalAnalysisCount
select effectiveAnalysisCount, sourceEffectiveAnalysisCount, totalAnalysisCount, effectivenessMetric