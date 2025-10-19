/**
 * 分析指向关系图的压缩效率指标：计算不同事实的数量、关系图的整体规模，
 * 以及它们在特定上下文深度下的压缩比率。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：不同事实数量、关系总规模、上下文深度和压缩比率
from int distinctFactsCount, int relationsTotalSize, int contextDepth, float compressionRatio
where
  // 确定当前分析的上下文深度
  exists(PointsToContext ctx | contextDepth = ctx.getDepth()) and
  
  // 统计不同事实的数量：计算唯一的(控制流节点, 目标对象, 类对象)组合数
  distinctFactsCount =
    strictcount(ControlFlowNode flowNode, Object targetObj, ClassObject classObj |
      exists(PointsToContext ctx |
        // 验证在指定上下文中，控制流节点指向目标对象，且目标对象是类对象的实例
        PointsTo::points_to(flowNode, ctx, targetObj, classObj, _) and
        ctx.getDepth() = contextDepth
      )
    ) and
    
  // 计算关系的总规模：统计所有(控制流节点, 目标对象, 类对象, 上下文, 源控制流节点)组合
  relationsTotalSize =
    strictcount(ControlFlowNode flowNode, Object targetObj, ClassObject classObj, 
      PointsToContext ctx, ControlFlowNode sourceFlowNode |
      // 验证在指定上下文中，控制流节点指向目标对象，且目标对象是类对象的实例，并记录源控制流节点
      PointsTo::points_to(flowNode, ctx, targetObj, classObj, sourceFlowNode) and
      ctx.getDepth() = contextDepth
    ) and
    
  // 计算压缩比率：不同事实数量占关系总规模的百分比
  compressionRatio = 100.0 * distinctFactsCount / relationsTotalSize

// 输出结果：上下文深度、不同事实数量、关系总规模和压缩比率
select contextDepth, distinctFactsCount, relationsTotalSize, compressionRatio