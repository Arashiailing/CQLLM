import python  // 导入Python分析库，提供Python代码分析的基础功能
import semmle.python.pointsto.PointsTo  // 导入PointsTo分析模块，支持指向分析功能

// 查找所有类型推断失败的类及其失败原因
from ClassValue classValue, string failureReason
where Types::failedInference(classValue, failureReason)
select classValue, failureReason