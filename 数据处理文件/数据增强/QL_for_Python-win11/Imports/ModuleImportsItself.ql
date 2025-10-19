/**
 * @name Module imports itself
 * @description A module imports itself
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// 定义一个谓词函数，用于判断模块是否导入自身
predicate modules_imports_itself(ImportingStmt i, ModuleValue m) {
  // 检查导入语句的封闭模块是否与给定模块相同
  i.getEnclosingModule() = m.getScope() and
  // 获取导入的模块名称并找到对应的模块值
  m =
    max(string s, ModuleValue m_ |
      s = i.getAnImportedModuleName() and
      m_.importedAs(s)
    |
      m_ order by s.length()
    )
}

// 从所有导入语句和模块值中查找满足条件的实例
from ImportingStmt i, ModuleValue m
where modules_imports_itself(i, m)
select i, "The module '" + m.getName() + "' imports itself."
