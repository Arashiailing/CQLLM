import python  // 导入Python语言分析模块，提供Python代码的解析和分析能力
import semmle.python.pointsto.PointsTo  // 导入指向分析模块，用于代码的可达性分析

/**
 * 查询目标：统计程序中所有不可执行的基本块数量
 * 
 * 不可达基本块是指在程序执行过程中永远不会被访问到的代码块。
 * 这类代码块通常是由死代码、不可达条件分支或异常处理路径导致的。
 */
from int unreachableBlockCount  // 声明整型变量，用于存储不可达基本块的总数
where unreachableBlockCount = 
  count(ControlFlowNode node | 
    // 筛选条件：节点所属的基本块不可达
    not PointsToInternal::reachableBlock(node.getBasicBlock(), _)
  )  
select unreachableBlockCount  // 输出不可达基本块的总数