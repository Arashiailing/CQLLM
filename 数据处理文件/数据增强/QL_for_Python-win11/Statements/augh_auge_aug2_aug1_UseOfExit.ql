/**
 * @name Python退出函数调用检测
 * @description 检测代码中对exit()或quit()函数的调用。当Python解释器使用-S选项启动时，
 *              这些函数可能无法正常工作，因为它们依赖于site模块的加载状态。
 *              如果site模块未被加载或被修改，调用这些函数会导致执行失败。
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // 导入Python分析库，提供对Python代码的静态分析支持

from CallNode exitFunctionCall, string exitFunctionName  // 定义查询范围：所有退出函数调用节点及对应的函数名称
where 
  // 验证函数调用是否引用了site模块中的退出器对象
  exists(Value targetValue |
    // 获取函数调用所引用的实际值
    targetValue = exitFunctionCall.getFunction().pointsTo() and
    // 检查该值是否为site模块定义的退出函数
    targetValue = Value::siteQuitter(exitFunctionName)
  )
select 
  exitFunctionCall,  // 选择匹配的函数调用节点作为结果
  "检测到对 '" + exitFunctionName + "' 的调用：在site模块未被加载或被修改的情况下，该函数调用可能无法正常工作。"  // 显示警告信息