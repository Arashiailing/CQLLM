/**
 * @name 指向关系分析质量评估
 * @description 本查询通过计算高价值分析结果在总体分析结果中的占比，
 * 评估指向关系分析的精确度和信息密度。该指标有助于量化分析引擎性能，
 * 特别是在过滤掉低价值节点（如参数、名称常量和不可变字面量）后的分析质量。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 判断控制流节点是否为低价值节点（即分析价值不高的节点）
predicate isTrivialNode(ControlFlowNode flowNode) {
  // 如果节点是以下类型之一，则认为其分析价值有限：函数参数、名称常量或不可变字面量
  flowNode.getNode() instanceof Parameter
  or
  flowNode instanceof NameConstantNode
  or
  flowNode.getNode() instanceof ImmutableLiteral
}

// 计算指向关系分析的质量指标
from 
  int highValueAnalysisCount,      // 高价值分析结果的总数
  int sourceHighValueCount,        // 源文件中的高价值分析结果数量
  int overallAnalysisCount,        // 所有指向关系分析结果的总数
  float analysisQualityMetric     // 分析质量指标评分
where
  // 计算高价值分析结果总数（排除低价值节点）
  highValueAnalysisCount =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject targetClass |
      flowNode.refersTo(targetObject, targetClass, _) and not isTrivialNode(flowNode)
    ) and
  // 计算源文件中的高价值分析结果数量
  sourceHighValueCount =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject targetClass |
      flowNode.refersTo(targetObject, targetClass, _) and
      not isTrivialNode(flowNode) and
      exists(flowNode.getScope().getEnclosingModule().getFile().getRelativePath())
    ) and
  // 计算所有指向关系分析结果的总数
  overallAnalysisCount =
    strictcount(ControlFlowNode flowNode, PointsToContext context, Object targetObject, 
      ClassObject targetClass, ControlFlowNode originalFlowNode | 
      PointsTo::points_to(flowNode, context, targetObject, targetClass, originalFlowNode)
    ) and
  // 计算分析质量指标：源文件高价值分析结果占总体分析结果的百分比
  analysisQualityMetric = 100.0 * sourceHighValueCount / overallAnalysisCount
select highValueAnalysisCount, sourceHighValueCount, overallAnalysisCount, analysisQualityMetric