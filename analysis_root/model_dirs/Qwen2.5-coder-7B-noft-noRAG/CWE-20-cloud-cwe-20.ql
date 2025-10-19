import python  // 导入python库，用于处理Python代码的解析和分析
import semmle.python.dataflow.new.DataFlow  // 导入数据流分析库，用于检测数据流路径
import semmle.python.ApiGraphs  // 导入API图库，用于识别系统调用
import semmle.python.security.dataflow.TaintTracking  // 导入污点跟踪库，用于检测潜在的安全问题