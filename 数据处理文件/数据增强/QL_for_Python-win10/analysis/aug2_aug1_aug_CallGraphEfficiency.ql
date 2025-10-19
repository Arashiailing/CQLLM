/**
 * 调用图结构密度与效率评估：分析调用图的信息密度和结构优化程度。
 * 本查询通过量化调用事实数量、关系规模、上下文深度及密度指标，
 * 评估调用图的数据压缩率和结构效率，为代码优化提供度量依据。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：factCount（调用事实总数）、relationCount（关系总规模）、contextDepth（上下文深度）和densityMetric（密度指标）
from int factCount, int relationCount, int contextDepth, float densityMetric
where
  // 统计调用事实总数：计算所有(调用节点, 被调用函数)二元组的数量
  // 同时获取上下文深度信息用于后续分析
  factCount =
    strictcount(ControlFlowNode callerNode, CallableValue calledFunction |
      exists(PointsToContext callContext |
        callerNode = calledFunction.getACall(callContext) and // 获取calledFunction在callContext中的调用节点callerNode
        contextDepth = callContext.getDepth() // 记录callContext的深度信息
      )
    ) and
  // 计算调用图关系总规模：统计所有(调用节点, 被调用函数, 调用上下文)三元组的数量
  // 复用相同的逻辑结构，确保计算一致性
  relationCount =
    strictcount(ControlFlowNode callerNode, CallableValue calledFunction, PointsToContext callContext |
      callerNode = calledFunction.getACall(callContext) and // 获取calledFunction在callContext中的调用节点callerNode
      contextDepth = callContext.getDepth() // 确保使用相同的上下文深度
    ) and
  // 计算密度指标：将事实总数转换为相对于关系总规模的百分比密度
  // 该指标反映了调用图的紧凑程度，值越高表示结构越紧凑
  densityMetric = 100.0 * factCount / relationCount
select contextDepth, factCount, relationCount, densityMetric // 返回上下文深度、调用事实总数、关系总规模和密度指标