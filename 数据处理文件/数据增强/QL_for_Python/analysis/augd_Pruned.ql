import python  // 导入Python分析库，提供Python代码解析与分析能力
import semmle.python.pointsto.PointsTo  // 引入Semmle Python指向性分析库，用于代码可达性分析

// 定义查询：计算程序中不可执行的基本块总数
// 不可达基本块指在程序执行过程中永远无法访问到的代码片段
from int unreachableCount  // 声明整型变量，用于存储不可达基本块的统计结果
where 
  // 统计所有不可达基本块的数量
  unreachableCount = count(ControlFlowNode blockNode | 
    // 检查当前控制流节点所属的基本块是否不可达
    // PointsToInternal::reachableBlock方法用于判断基本块在程序执行时是否可被访问
    not PointsToInternal::reachableBlock(blockNode.getBasicBlock(), _)
  )
select unreachableCount  // 返回不可达基本块的总数作为查询结果