import python  // 导入Python代码分析库，提供Python语言的AST和语义分析功能
import semmle.python.pointsto.PointsTo  // 导入PointsTo分析模块，用于跟踪对象引用关系

// 查找类型推断失败的类值及其失败原因
from ClassValue classValue, string failureReason
// 筛选出类型推断失败的类值
where Types::failedInference(classValue, failureReason)
// 返回类型推断失败的类值及其失败原因
select classValue, failureReason