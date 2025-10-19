/**
 * @name 使用exit()或quit()函数
 * @description 检测代码中对exit()或quit()函数的调用。这些函数依赖于site模块，
 *              当Python解释器以-S选项启动时，site模块不会被加载，导致这些函数调用失败。
 *              在site模块被修改或不可用的环境中，这些调用也可能无法正常工作。
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // 引入Python代码分析库，提供静态分析Python代码的能力

from CallNode exitCall, string exitFuncName  // 定义查询范围：函数调用节点和退出函数名称
where 
  // 检查当前调用是否指向site模块中的退出函数
  exists(Value pointedValue |
    // 获取函数调用所引用的实际值
    pointedValue = exitCall.getFunction().pointsTo() and
    // 确认该值是site模块中定义的退出函数
    pointedValue = Value::siteQuitter(exitFuncName)
  )
select 
  exitCall,  // 选择符合条件的函数调用节点
  "发现对 '" + exitFuncName + "' 的调用：当site模块未被加载或被修改时，此函数调用可能无法正常执行。"  // 显示警告消息