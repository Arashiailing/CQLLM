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

// 导入Python库，提供分析Python代码所需的基础功能
import python

// 根据Python版本生成相应的警告消息的函数
string getAlertMessage() {
  // 检测Python主版本号，返回版本对应的警告文本
  major_version() = 2 and result = "The 'exec' statement is used."
  or
  major_version() = 3 and result = "The 'exec' function is used."
}

// 判断给定的调用节点是否为exec函数调用的谓词
predicate isExecFunctionInvocation(Call funcCall) {
  // 查找名为'exec'的全局变量，并确认该函数调用引用了此变量
  exists(GlobalVariable execVar | 
    execVar = funcCall.getFunc().(Name).getVariable() and 
    execVar.getId() = "exec"
  )
}

// 主查询：查找所有使用exec语句或函数的代码节点
from AstNode dangerousExecNode
// 筛选条件：节点是exec函数调用或者是exec语句
where 
  isExecFunctionInvocation(dangerousExecNode) or 
  dangerousExecNode instanceof Exec
// 返回检测结果和相应的警告消息
select dangerousExecNode, getAlertMessage()