/**
 * 本查询分析 Python 代码中的指向关系统计信息。
 * 计算三个关键指标：
 * 1. 指向关系的事实总数 - 不同(f, value, cls)组合的数量
 * 2. 指向关系的总大小 - 所有(f, value, cls, ctx, orig)组合的数量
 * 3. 效率比率 - 事实总数与总大小的百分比
 * 所有计算都基于特定的上下文深度。
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// 定义查询输出变量：事实数量、关系大小、上下文深度和效率比率
from int factCount, int relationSize, int contextDepth, float efficiencyRatio
where
  // 步骤1: 计算指向关系的事实总数
  factCount =
    strictcount(ControlFlowNode flowNode, Object value, ClassObject classObj |
      exists(PointsToContext context |
        // 检查是否存在一个上下文，使得在该上下文中flowNode指向value且classObj为类对象
        PointsTo::points_to(flowNode, context, value, classObj, _) and
        // 记录当前上下文的深度
        contextDepth = context.getDepth()
      )
    ) and
  // 步骤2: 计算指向关系的总大小（包含所有上下文和原始节点信息）
  relationSize =
    strictcount(ControlFlowNode flowNode, Object value, ClassObject classObj, 
      PointsToContext context, ControlFlowNode originNode |
      // 检查在指定上下文中flowNode是否指向value且classObj为类对象
      PointsTo::points_to(flowNode, context, value, classObj, originNode) and
      // 确保使用相同的上下文深度进行计算
      contextDepth = context.getDepth()
    ) and
  // 步骤3: 计算效率比率（转换为百分比形式）
  efficiencyRatio = 100.0 * factCount / relationSize
// 输出结果：上下文深度、事实总数、总大小和效率比率
select contextDepth, factCount, relationSize, efficiencyRatio