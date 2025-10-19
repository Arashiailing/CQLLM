/**
 * @name Importing value of mutable attribute
 * @description Directly importing a mutable attribute's value can lead to inconsistencies, as local copies will not reflect subsequent changes in the global state.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity high
 * @precision medium
 * @id py/import-of-mutable-attribute
 */

// 导入Python库和测试过滤器
import python
import semmle.python.filters.Tests

// 从模块导入成员并获取相关属性节点和名称
from ImportMember importMember, ModuleValue moduleVal, AttrNode attributeStore, string attributeName
where
  // 验证导入模块与当前模块匹配
  moduleVal.importedAs(importMember.getModule().(ImportExpr).getImportedModuleName()) and
  // 确保导入成员名称与目标属性名称一致
  importMember.getName() = attributeName and
  // 属性修改必须发生在函数作用域内
  attributeStore.getScope() instanceof Function and
  // 导入变量必须具有模块级生命周期
  not importMember.getScope() instanceof Function and
  // 确认是属性存储操作
  attributeStore.isStore() and
  // 验证属性对象指向导入的模块
  attributeStore.getObject(attributeName).pointsTo(moduleVal) and
  // 确保导入和修改不在同一模块中
  not importMember.getEnclosingModule() = attributeStore.getScope().getEnclosingModule() and
  // 排除测试代码中的修改
  not attributeStore.getScope().getScope*() instanceof TestScope
select importMember,
  "Importing the value of '" + attributeName +
    "' from $@ means that any change made to $@ will not be observed locally.", moduleVal,
  "module " + moduleVal.getName(), attributeStore, moduleVal.getName() + "." + attributeStore.getName()