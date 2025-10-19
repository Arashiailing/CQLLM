/**
 * @name 'exec' used
 * @description The 'exec' statement or function is used which could cause arbitrary code to be executed.
 * @kind problem
 * @tags security
 *       correctness
 * @problem.severity error
 * @security-severity 4.2
 * @sub-severity high
 * @precision low
 * @id py/use-of-exec
 */

// 导入Python库，用于处理Python代码的解析和分析
import python

// 定义一个返回字符串的函数message()，用于生成错误消息
string message() {
  // 如果Python的主版本是2，则返回"使用了'exec'语句"的消息
  result = "The 'exec' statement is used." and major_version() = 2
  // 如果Python的主版本是3，则返回"使用了'exec'函数"的消息
  or
  result = "The 'exec' function is used." and major_version() = 3
}

// 定义一个谓词exec_function_call(Call c)，用于判断是否调用了'exec'函数
predicate exec_function_call(Call c) {
  // 检查是否存在全局变量名为'exec'且被调用的情况
  exists(GlobalVariable exec | exec = c.getFunc().(Name).getVariable() and exec.getId() = "exec")
}

// 从抽象语法树节点中选择所有满足条件的'exec'节点
from AstNode exec
// 条件：调用了'exec'函数或实例是Exec语句
where exec_function_call(exec) or exec instanceof Exec
// 选择结果包括'exec'节点和相应的错误消息
select exec, message()
