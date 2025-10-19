/**
 * @name 使用exit()或quit()函数
 * @description 当Python解释器以-S选项启动时，调用exit()或quit()函数可能导致执行失败，
 *              因为这些函数依赖于site模块的加载。如果site模块未被加载或被修改，
 *              这些函数调用可能无法正常工作。
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // 导入Python分析库，提供对Python代码的静态分析能力

from CallNode funcCallNode, string quitterFuncName  // 定义查询范围：所有函数调用节点及对应的退出函数名称
where 
  // 检查函数调用是否引用了site模块中的退出器对象
  exists(Value referencedValue |
    // 获取函数调用所引用的实际值
    referencedValue = funcCallNode.getFunction().pointsTo() and
    // 验证该值是否为site模块中的退出器对象
    referencedValue = Value::siteQuitter(quitterFuncName)
  )
select 
  funcCallNode,  // 选择匹配的函数调用节点作为结果
  "检测到对 '" + quitterFuncName + "' 的调用：在site模块未被加载或被修改的情况下，该函数调用可能无法正常工作。"  // 显示警告信息