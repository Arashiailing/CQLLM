/**
 * @name Csv Injection
 * @description 检测潜在的CSV注入漏洞，其中用户控制的数据被保存到CSV文件中，
 *              当在电子表格软件中打开时，可能导致信息泄露或其他恶意活动
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
from CsvInjectionFlow::PathNode userInputSource, CsvInjectionFlow::PathNode csvOutputSink

// 条件：如果存在从源节点到汇节点的数据流路径
where CsvInjectionFlow::flowPath(userInputSource, csvOutputSink)

// 选择并返回以下信息：
select csvOutputSink.getNode(), userInputSource, csvOutputSink, "Csv injection might include code from $@.", userInputSource.getNode(),
  "this user input"