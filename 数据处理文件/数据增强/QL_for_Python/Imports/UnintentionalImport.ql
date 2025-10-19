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

// 导入Python库，用于分析Python代码
import python

// 定义谓词函数 import_star，用于检查是否使用了 'import *' 语法
predicate import_star(ImportStar imp, ModuleValue exporter) {
  // 检查导出模块的名称是否与导入的模块名称匹配
  exporter.importedAs(imp.getImportedModuleName())
}

// 定义谓词函数 all_defined，用于检查模块是否定义了 '__all__'
predicate all_defined(ModuleValue exporter) {
  // 如果模块是内建模块，则返回 true
  exporter.isBuiltin()
  or
  // 如果模块的作用域定义了 '__all__'，则返回 true
  exporter.getScope().(ImportTimeScope).definesName("__all__")
  or
  // 如果模块的初始化模块定义了 '__all__'，则返回 true
  exporter.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// 从所有使用 'import *' 语法的导入语句和模块中进行查询
from ImportStar imp, ModuleValue exporter
where import_star(imp, exporter) and not all_defined(exporter) and not exporter.isAbsent()
select imp,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  exporter, exporter.getName()
