/**
 * 调用图结构分析：评估调用图的紧凑度与效率指标。
 * 通过量化调用事实、关系规模、上下文深度并计算密度指标，
 * 提供调用图数据压缩效率和结构优化潜力的度量。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 输出变量定义：totalCallFacts（调用事实总数）、totalCallRelations（关系总规模）、
// contextDepth（上下文深度）和densityMetric（密度指标）
from int totalCallFacts, int totalCallRelations, int contextDepth, float densityMetric
where
  // 第一阶段：提取调用事实并确定上下文深度
  exists(ControlFlowNode callerNode, CallableValue targetFunction |
    exists(PointsToContext callContext |
      // 获取调用关系并记录上下文深度
      callerNode = targetFunction.getACall(callContext) and
      contextDepth = callContext.getDepth()
    )
  ) and
  // 第二阶段：计算调用事实总数（调用节点-目标函数二元组）
  totalCallFacts =
    strictcount(ControlFlowNode callerNode, CallableValue targetFunction |
      exists(PointsToContext callContext |
        callerNode = targetFunction.getACall(callContext) and
        contextDepth = callContext.getDepth()
      )
    ) and
  // 第三阶段：计算调用关系总规模（调用节点-目标函数-上下文三元组）
  totalCallRelations =
    strictcount(ControlFlowNode callerNode, CallableValue targetFunction, PointsToContext callContext |
      callerNode = targetFunction.getACall(callContext) and
      contextDepth = callContext.getDepth()
    ) and
  // 第四阶段：计算密度指标（事实总数占关系规模的百分比）
  densityMetric = 100.0 * totalCallFacts / totalCallRelations
select contextDepth, totalCallFacts, totalCallRelations, densityMetric // 返回分析结果：上下文深度、调用事实数、关系规模和密度指标