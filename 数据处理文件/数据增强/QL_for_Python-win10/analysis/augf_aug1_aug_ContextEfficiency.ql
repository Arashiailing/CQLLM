/**
 * 分析指向关系图的压缩性能指标：
 * 1. 统计不同事实的数量（不包含上下文和源节点信息）
 * 2. 计算关系图的总大小（包含完整上下文和源节点信息）
 * 3. 评估压缩效率百分比（表示去重后的压缩程度）
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 声明查询结果变量：去重事实数、关系总数、上下文深度和压缩比率
from int distinctFactsCount, int totalRelationsSize, int contextDepth, float compressionRatio
where
  // 确定当前分析的上下文深度
  exists(PointsToContext context | contextDepth = context.getDepth()) and
  // 计算去重后的指向关系事实数量（忽略上下文和源节点差异）
  distinctFactsCount =
    strictcount(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject classObject |
      exists(PointsToContext context |
        // 验证在指定上下文中，控制流节点指向对象，且该对象属于特定类
        PointsTo::points_to(controlFlowNode, context, pointedObject, classObject, _) and
        context.getDepth() = contextDepth
      )
    ) and
  // 计算完整的指向关系总数（包含上下文和源节点信息）
  totalRelationsSize =
    strictcount(ControlFlowNode controlFlowNode, Object pointedObject, ClassObject classObject, 
      PointsToContext context, ControlFlowNode sourceControlFlowNode |
      // 验证完整的指向关系，包括源控制流节点信息
      PointsTo::points_to(controlFlowNode, context, pointedObject, classObject, sourceControlFlowNode) and
      context.getDepth() = contextDepth
    ) and
  // 计算压缩比率：去重事实数占总关系数的百分比
  compressionRatio = 100.0 * distinctFactsCount / totalRelationsSize
// 输出分析结果：上下文深度、去重事实数、关系总数和压缩比率
select contextDepth, distinctFactsCount, totalRelationsSize, compressionRatio