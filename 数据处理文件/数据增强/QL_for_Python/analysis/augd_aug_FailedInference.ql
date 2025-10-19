import python  // 导入Python代码分析的基础库，支持语法和结构分析
import semmle.python.pointsto.PointsTo  // 引入指向分析功能，用于追踪对象引用关系

// 识别类型推断过程中出错的类对象及其对应的错误信息
// 此查询用于发现静态分析中无法确定类型的类定义，帮助定位类型系统推断的瓶颈
from ClassValue classObj, string errorMsg
where Types::failedInference(classObj, errorMsg)
select classObj, errorMsg