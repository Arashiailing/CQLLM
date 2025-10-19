/**
 * 评估指向关系图的数据压缩效能：通过计算唯一事实条目数、关系图总体积，
 * 并确定它们相对于上下文层级的压缩效率百分比。
 * 此查询为点对分析中数据结构的空间优化提供量化评估依据。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 声明查询输出参数：唯一事实计数、关系总体积、上下文层级和压缩效率百分比
from int uniqueFactsCount, int totalRelationsSize, int ctxDepth, float compressionRate
where
  // 确定当前分析的上下文层级深度
  exists(PointsToContext context | ctxDepth = context.getDepth()) and
  // 计算唯一事实数量：统计不同的(流控制节点, 目标对象, 类对象)元组
  uniqueFactsCount =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject clsObject |
      exists(PointsToContext context |
        // 验证在指定上下文中，流控制节点指向目标对象，且该对象是类对象的实例
        PointsTo::points_to(flowNode, context, targetObject, clsObject, _) and
        context.getDepth() = ctxDepth
      )
    ) and
  // 计算关系总体积：统计所有(流控制节点, 目标对象, 类对象, 上下文, 源流控制节点)元组
  totalRelationsSize =
    strictcount(ControlFlowNode flowNode, Object targetObject, ClassObject clsObject, 
      PointsToContext context, ControlFlowNode sourceFlowNode |
      // 验证在指定上下文中，流控制节点指向目标对象，且该对象是类对象的实例，并记录源流控制节点
      PointsTo::points_to(flowNode, context, targetObject, clsObject, sourceFlowNode) and
      context.getDepth() = ctxDepth
    ) and
  // 计算压缩效率百分比：唯一事实数量占关系总体积的比例
  compressionRate = 100.0 * uniqueFactsCount / totalRelationsSize
// 输出结果：上下文层级、唯一事实计数、关系总体积和压缩效率百分比
select ctxDepth, uniqueFactsCount, totalRelationsSize, compressionRate