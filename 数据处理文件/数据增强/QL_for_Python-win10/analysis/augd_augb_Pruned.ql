import python  // 导入Python语言分析模块，提供Python代码的解析、分析和建模功能
import semmle.python.pointsto.PointsTo  // 导入指向分析模块，用于执行程序可达性分析和数据流跟踪

/**
 * 查询目标：统计程序中所有不可执行的基本块数量
 * 
 * 不可执行基本块（也称为死代码块）是指在程序任何可能的执行路径上
 * 都无法被访问到的代码块。这类代码块通常由以下原因导致：
 * 1. 死代码残留（如调试代码或废弃功能）
 * 2. 永远为false的条件分支
 * 3. 无法到达的异常处理路径
 * 4. 未被调用的函数或方法
 * 
 * 本查询通过分析控制流图和可达性信息来识别这些不可达基本块，
 * 并返回它们的总数，帮助开发人员识别和清理死代码。
 */
from int deadBasicBlockCount  // 声明整型变量，用于存储不可达基本块的总数
where 
  // 计算所有满足不可达条件的基本块数量
  deadBasicBlockCount = count(ControlFlowNode flowNode | 
    // 筛选条件：控制流节点所属的基本块在程序执行过程中不可达
    // PointsToInternal::reachableBlock检查基本块是否可达
    // 第二个参数_表示我们不关心具体的调用上下文
    not PointsToInternal::reachableBlock(flowNode.getBasicBlock(), _)
  )  
select deadBasicBlockCount  // 输出不可达基本块的总数，作为代码质量指标