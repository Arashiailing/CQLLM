/**
 * @name Csv Injection
 * @description 检测潜在CSV注入漏洞：当用户控制的数据被写入CSV文件时，
 *              可能在电子表格软件中打开时执行恶意代码导致信息泄露
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// 导入Python代码分析基础库
import python

// 导入CSV注入数据流路径图模块
import CsvInjectionFlow::PathGraph

// 导入数据流跟踪分析模块
import semmle.python.dataflow.new.DataFlow

// 导入实验性CSV注入检测模块
import experimental.semmle.python.security.injection.CsvInjection

// 定义数据流源节点和汇节点
from CsvInjectionFlow::PathNode untrustedInputSource, CsvInjectionFlow::PathNode csvFileSink

// 检查是否存在从不可信输入源到CSV文件输出的数据流路径
where CsvInjectionFlow::flowPath(untrustedInputSource, csvFileSink)

// 输出检测结果：
select csvFileSink.getNode(), 
       untrustedInputSource, 
       csvFileSink, 
       "Csv injection might include code from $@.", 
       untrustedInputSource.getNode(),
       "this user input"