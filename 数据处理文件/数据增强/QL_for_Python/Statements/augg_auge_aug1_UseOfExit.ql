/**
 * @name 调用exit()或quit()函数
 * @description 识别代码中对exit()或quit()函数的调用。这些函数在Python解释器使用-S选项启动时可能导致执行失败，
 *              因为它们依赖于site模块，而-S选项会禁用site模块的自动导入。
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python

from CallNode terminationCall, string quitFuncName
where 
  // 验证函数调用是否指向site模块中的Quitter对象（exit或quit）
  terminationCall.getFunction().pointsTo(Value::siteQuitter(quitFuncName))
select 
  terminationCall,
  "调用 '" + quitFuncName + "' 可能存在问题：当'site'模块未加载或被修改时，site.Quitter对象可能不可用。"