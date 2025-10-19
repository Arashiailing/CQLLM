import python  // 导入Python分析模块，提供Python代码的语法解析和语义分析能力
import semmle.python.pointsto.PointsTo  // 导入指向分析模块，用于追踪变量引用和代码可达性

// 本查询用于检测Python代码中的不可达基本块数量
// 不可达基本块是指程序执行路径中永远不会被访问的代码片段，通常表明存在死代码
from int unreachableBlockCount  // 声明一个整型变量，用于存储统计结果
where 
  // 计算所有不可达基本块的总数
  unreachableBlockCount = count(ControlFlowNode node | 
    // 筛选条件：找到所有不可达的基本块
    // PointsToInternal::reachableBlock() 判断基本块在程序执行中是否可达
    not PointsToInternal::reachableBlock(node.getBasicBlock(), _)
  )
select unreachableBlockCount  // 输出不可达基本块的总数