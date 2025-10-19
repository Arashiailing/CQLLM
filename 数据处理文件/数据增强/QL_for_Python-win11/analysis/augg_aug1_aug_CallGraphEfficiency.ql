/**
 * 调用图结构分析：量化评估调用图的密度与效率。
 * 本查询通过计算调用事实数量、关系规模、上下文深度以及密度比率，
 * 来分析调用图的数据密度和结构效率，为代码优化提供量化依据。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义输出变量：factCount（调用事实总数）、relationCount（关系总规模）、contextDepth（上下文深度）和densityRatio（密度比率）
from int factCount, int relationCount, int contextDepth, float densityRatio
where
  // 第一部分：计算调用图中的事实总数
  // 统计所有(调用点, 被调用函数)对的数量，反映调用图的基本规模
  factCount =
    strictcount(ControlFlowNode callSite, CallableValue callee |
      exists(PointsToContext callContext |
        callSite = callee.getACall(callContext) and // 获取callee在callContext中的调用点callSite
        contextDepth = callContext.getDepth() // 记录callContext的深度
      )
    ) and
  // 第二部分：计算调用图关系的总规模
  // 统计所有(调用点, 被调用函数, 调用上下文)三元组的数量，反映调用图的详细程度
  relationCount =
    strictcount(ControlFlowNode callSite, CallableValue callee, PointsToContext callContext |
      callSite = callee.getACall(callContext) and // 获取callee在callContext中的调用点callSite
      contextDepth = callContext.getDepth() // 记录callContext的深度
    ) and
  // 第三部分：计算密度比率
  // 将事实总数转换为相对于关系总规模的百分比，反映调用图的紧凑程度
  densityRatio = 100.0 * factCount / relationCount
select contextDepth, factCount, relationCount, densityRatio // 返回上下文深度、调用事实总数、关系总规模和密度比率