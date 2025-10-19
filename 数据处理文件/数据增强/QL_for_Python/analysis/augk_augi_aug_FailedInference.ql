import python  // 引入Python代码分析的核心库，用于基础代码解析
import semmle.python.pointsto.PointsTo  // 引入指向分析模块，支持变量和对象的引用追踪

// 检测Python代码中类型推断失败的类实例，并收集相关错误详情
// 该查询帮助开发者定位类型系统无法确定具体类型的类定义

// 定义类型推断失败的类和错误信息
from ClassValue typeInferenceFailure, string failureMessage
where 
  // 应用类型推断失败检测条件
  Types::failedInference(typeInferenceFailure, failureMessage)
select 
  // 输出类型推断失败的类和对应的错误信息
  typeInferenceFailure, 
  failureMessage