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

// 导入Python分析库
import python

// 查询所有使用通配符导入且未定义__all__的模块
from ImportStar wildcardImport, ModuleValue sourceModule
where 
  // 验证导入模块与源模块名称匹配
  sourceModule.importedAs(wildcardImport.getImportedModuleName())
  and not (
    // 排除已定义__all__的模块（包括内建模块）
    sourceModule.isBuiltin()
    or sourceModule.getScope().(ImportTimeScope).definesName("__all__")
    or sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
  )
  // 确保源模块存在
  and not sourceModule.isAbsent()
select wildcardImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()