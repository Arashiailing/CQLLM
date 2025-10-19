/**
 * @name Csv Injection
 * @description From user-controlled data saved in CSV files, it is easy to attempt information disclosure
 *              or other malicious activities when automated by spreadsheet software
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// 导入Python库，用于处理Python代码的解析和分析
import python

// 导入CsvInjectionFlow路径图，用于表示CSV注入数据流路径
import CsvInjectionFlow::PathGraph

// 导入数据流分析模块，用于跟踪数据在程序中的流动
import semmle.python.dataflow.new.DataFlow

// 导入实验性的CSV注入检测模块
import experimental.semmle.python.security.injection.CsvInjection

// 定义数据流源节点和汇节点
from CsvInjectionFlow::PathNode source, CsvInjectionFlow::PathNode sink

// 条件：如果存在从源节点到汇节点的数据流路径
where CsvInjectionFlow::flowPath(source, sink)

// 选择并返回以下信息：
select sink.getNode(), source, sink, "Csv injection might include code from $@.", source.getNode(),
  "this user input"
