/**
 * 调用图复用效率分析器：测量调用图中节点在不同上下文中的复用模式。
 * 此查询量化了调用图的压缩特性，通过计算相同调用在不同上下文中的重复使用情况。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：ctxDepth（上下文深度）、totalCallFacts（调用事实总数）、
// totalRelationSize（关系总规模）和reuseEfficiency（复用效率）
from int ctxDepth, int totalCallFacts, int totalRelationSize, float reuseEfficiency
where
  // 首先确定上下文深度，并以此为基础计算调用图的关键指标
  exists(PointsToContext depthCtx |
    ctxDepth = depthCtx.getDepth() and // 提取当前分析的上下文深度
    
    // 计算调用事实总数：统计不同(ControlFlowNode, CallableValue)组合的数量
    totalCallFacts = strictcount(ControlFlowNode invocationNode, CallableValue calledFunction |
      exists(PointsToContext invocationCtx |
        invocationNode = calledFunction.getACall(invocationCtx) and // 验证调用关系
        invocationCtx.getDepth() = ctxDepth // 确保在相同深度下进行统计
      )
    ) and
    
    // 计算关系总规模：统计包含上下文信息的(ControlFlowNode, CallableValue, PointsToContext)三元组数量
    totalRelationSize = strictcount(ControlFlowNode invocationNode, CallableValue calledFunction, PointsToContext invocationCtx |
      invocationNode = calledFunction.getACall(invocationCtx) and // 验证调用关系
      invocationCtx.getDepth() = ctxDepth // 确保在相同深度下进行统计
    ) and
    
    // 计算复用效率：调用事实总数与关系总规模的比率，转换为百分比
    // 该值越高，表示相同调用在不同上下文中的复用程度越高
    reuseEfficiency = 100.0 * totalCallFacts / totalRelationSize
  )
select ctxDepth, totalCallFacts, totalRelationSize, reuseEfficiency // 返回分析结果：上下文深度、调用事实总数、关系总规模和复用效率