/**
 * @name Csv Injection
 * @description 检测潜在的CSV注入漏洞，当用户控制的数据未经适当处理就被写入CSV文件时，
 *              可能在电子表格软件中打开时执行恶意公式或命令，导致信息泄露或其他安全风险
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// 导入Python代码分析基础库
import python

// 导入数据流分析框架，用于跟踪数据在程序执行过程中的传播
import semmle.python.dataflow.new.DataFlow

// 导入CSV注入数据流路径图，用于追踪潜在漏洞的数据传播路径
import CsvInjectionFlow::PathGraph

// 导入实验性CSV注入检测模块，提供特定的安全分析功能
import experimental.semmle.python.security.injection.CsvInjection

// 定义数据流分析的起点（用户输入）和终点（CSV输出）
from CsvInjectionFlow::PathNode userInput, CsvInjectionFlow::PathNode csvOutput

// 筛选条件：存在从用户输入到CSV输出的数据流路径
where CsvInjectionFlow::flowPath(userInput, csvOutput)

// 输出结果：CSV输出节点、用户输入节点、完整路径、描述信息以及用户输入节点的具体引用
select csvOutput.getNode(), userInput, csvOutput, "Csv injection might include code from $@.", userInput.getNode(),
  "this user input"