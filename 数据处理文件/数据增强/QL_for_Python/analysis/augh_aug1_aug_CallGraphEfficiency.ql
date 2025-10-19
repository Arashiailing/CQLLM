/**
 * 调用图结构效率评估：分析调用图的密度特征与结构优化程度。
 * 本查询通过量化调用事实数量、关系规模、上下文深度以及密度比率，
 * 来评估调用图的数据压缩效率和结构优化水平。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：callFactCount（调用事实总数）、relationTotalSize（关系总规模）、contextDepth（上下文深度）和densityRatio（密度比率）
from int callFactCount, int relationTotalSize, int contextDepth, float densityRatio
where
  // 计算调用图中的事实总数：统计所有(调用点, 被调用函数)对的数量
  callFactCount =
    strictcount(ControlFlowNode callSite, CallableValue callee |
      exists(PointsToContext callContext |
        callSite = callee.getACall(callContext) and // 获取callee在callContext中的调用点callSite
        contextDepth = callContext.getDepth() // 记录callContext的深度
      )
    ) and
  // 计算调用图关系的总规模：统计所有(调用点, 被调用函数, 调用上下文)三元组的数量
  relationTotalSize =
    strictcount(ControlFlowNode callSite, CallableValue callee, PointsToContext callContext |
      callSite = callee.getACall(callContext) and // 获取callee在callContext中的调用点callSite
      contextDepth = callContext.getDepth() // 记录callContext的深度
    ) and
  // 计算密度比率：将事实总数转换为相对于关系总规模的百分比
  densityRatio = 100.0 * callFactCount / relationTotalSize
select contextDepth, callFactCount, relationTotalSize, densityRatio // 返回上下文深度、调用事实总数、关系总规模和密度比率