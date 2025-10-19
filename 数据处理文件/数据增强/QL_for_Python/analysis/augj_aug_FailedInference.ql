import python  // 引入Python语言分析支持库，为代码分析提供基础功能
import semmle.python.pointsto.PointsTo  // 引入指向分析模块，用于跟踪变量和对象的引用关系

// 识别并返回所有类型推断过程中出现问题的Python类，以及导致推断失败的具体原因
from ClassValue failedClass, string inferenceFailureCause
where Types::failedInference(failedClass, inferenceFailureCause)
select failedClass, inferenceFailureCause