/**
 * @name 调用exit()或quit()函数
 * @description 在使用-S选项启动Python解释器时，调用exit()或quit()可能导致执行失败，因为这些函数依赖于site模块的加载。
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // 引入Python分析库，提供对Python代码的静态分析能力

from CallNode callNode, string exitFuncName  // 定义查询范围：所有函数调用节点及对应的退出函数名称
where 
  // 检查函数调用是否引用了site模块中的退出器对象
  exists(Value targetValue |
    targetValue = callNode.getFunction().pointsTo() and
    targetValue = Value::siteQuitter(exitFuncName)
  )
select 
  callNode,  // 选择匹配的函数调用节点作为结果
  "检测到对 '" + exitFuncName + "' 的调用：在site模块未被加载或被修改的情况下，该函数调用可能无法正常工作。"  // 显示警告信息