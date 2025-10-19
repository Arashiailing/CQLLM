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

// 引入Python分析模块，用于处理Python代码的静态分析
import python

// 根据当前分析的Python版本返回相应的告警信息
string generateAlertText() {
  // 判断主版本号，为不同版本生成对应的告警文本
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// 判断指定调用节点是否为exec函数调用
predicate isExecCall(Call callNode) {
  // 检查是否存在名为'exec'的全局变量，且该函数调用引用了此变量
  exists(GlobalVariable execGlobalVar | 
    execGlobalVar = callNode.getFunc().(Name).getVariable() and 
    execGlobalVar.getId() = "exec"
  )
}

// 主查询：检测所有使用exec的代码位置
from AstNode riskyExecUsage
// 筛选条件：节点为exec函数调用或exec语句
where 
  isExecCall(riskyExecUsage) or 
  riskyExecUsage instanceof Exec
// 输出结果：包含问题节点和相应的告警信息
select riskyExecUsage, generateAlertText()