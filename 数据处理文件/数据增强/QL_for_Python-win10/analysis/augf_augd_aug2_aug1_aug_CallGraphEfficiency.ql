/**
 * 调用图结构效率分析：评估Python代码中调用图的紧凑性和优化潜力。
 * 本查询通过计算调用事实数量、关系规模、上下文深度并推导密度指标，
 * 量化调用图的结构效率和数据压缩率，为代码重构提供数据支持。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：totalCallFacts（调用事实总数）、totalCallRelations（关系总规模）、
// contextDepth（上下文深度）和graphDensity（调用图密度指标）
from int totalCallFacts, int totalCallRelations, int contextDepth, float graphDensity
where
  // 分析调用图结构并计算各项指标
  exists(int currentDepth |
    // 计算调用事实总数：统计所有(调用节点, 被调用函数)二元组的数量
    // 这反映了不考虑上下文信息时的调用关系数量
    totalCallFacts = strictcount(ControlFlowNode callerNode, CallableValue calledFunction |
      exists(PointsToContext callContext |
        callerNode = calledFunction.getACall(callContext) and // 获取被调用函数在调用上下文中的调用节点
        currentDepth = callContext.getDepth() // 记录调用上下文的深度
      )
    ) and
    
    // 计算调用图关系总规模：统计所有(调用节点, 被调用函数, 调用上下文)三元组的数量
    // 这反映了考虑上下文信息时的调用关系数量，通常大于调用事实总数
    totalCallRelations = strictcount(ControlFlowNode callerNode, CallableValue calledFunction, PointsToContext callContext |
      callerNode = calledFunction.getACall(callContext) and // 获取被调用函数在调用上下文中的调用节点
      currentDepth = callContext.getDepth() // 确保使用相同的上下文深度
    ) and
    
    // 设置上下文深度值，用于后续分析
    contextDepth = currentDepth
  ) and
  
  // 计算调用图密度指标：将调用事实总数转换为相对于关系总规模的百分比密度
  // 该指标反映调用图的紧凑程度，值越高表示结构越紧凑，优化潜力越小
  // 密度 = (调用事实总数 / 关系总规模) * 100%
  graphDensity = 100.0 * totalCallFacts / totalCallRelations
select contextDepth, totalCallFacts, totalCallRelations, graphDensity // 返回上下文深度、调用事实总数、关系总规模和调用图密度指标