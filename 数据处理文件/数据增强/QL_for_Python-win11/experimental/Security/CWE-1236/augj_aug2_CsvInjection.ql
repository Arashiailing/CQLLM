/**
 * @name Csv Injection
 * @description 检测用户控制数据写入CSV文件导致的潜在注入漏洞，
 *              当在电子表格软件中打开时可能触发恶意代码执行或信息泄露
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// 导入Python代码分析核心库
import python

// 导入CSV注入数据流路径图模块
import CsvInjectionFlow::PathGraph

// 导入数据流分析框架
import semmle.python.dataflow.new.DataFlow

// 导入实验性CSV注入检测模块
import experimental.semmle.python.security.injection.CsvInjection

// 定义数据流分析中的源节点和汇节点
from CsvInjectionFlow::PathNode sourceNode, CsvInjectionFlow::PathNode sinkNode

// 验证是否存在从用户输入源到CSV输出点的数据流路径
where CsvInjectionFlow::flowPath(sourceNode, sinkNode)

// 输出检测结果：包含漏洞位置、攻击路径和描述信息
select sinkNode.getNode(), sourceNode, sinkNode, "Csv injection might include code from $@.", sourceNode.getNode(),
  "this user input"