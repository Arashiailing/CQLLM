/**
 * @name 'import *' may pollute namespace
 * @description Importing a module using 'import *' may unintentionally pollute the global
 *              namespace if the module does not define `__all__`
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

import python

// 检查导入语句是否使用 'import *' 语法并关联源模块
predicate matchesStarImport(ImportStar starImport, ModuleValue sourceModule) {
  // 验证源模块名称与导入模块名称匹配
  sourceModule.importedAs(starImport.getImportedModuleName())
}

// 检查模块是否定义了 '__all__' 以控制导出内容
predicate definesAllAttribute(ModuleValue sourceModule) {
  // 内建模块默认视为已定义 '__all__'
  sourceModule.isBuiltin()
  or
  // 检查模块作用域是否显式定义 '__all__'
  sourceModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // 检查模块初始化文件是否定义 '__all__'
  sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// 查询所有可能污染命名空间的 'import *' 语句
from ImportStar starImport, ModuleValue sourceModule
where 
  // 关联导入语句与源模块
  matchesStarImport(starImport, sourceModule)
  // 排除已定义 '__all__' 的模块
  and not definesAllAttribute(sourceModule)
  // 确保源模块存在
  and not sourceModule.isAbsent()
select starImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()