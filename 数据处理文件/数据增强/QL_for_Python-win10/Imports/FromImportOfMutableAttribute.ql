/**
 * @name Importing value of mutable attribute
 * @description Importing the value of a mutable attribute directly means that changes in global state will not be observed locally.
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

// 从模块中导入成员，并获取相关属性节点和名称
from ImportMember im, ModuleValue m, AttrNode store_attr, string name
where
  // 确保导入的模块与当前模块匹配
  m.importedAs(im.getModule().(ImportExpr).getImportedModuleName()) and
  // 确保导入的成员名称与给定的名称匹配
  im.getName() = name and
  /* 修改必须在函数内进行，以便在导入值的生命周期内发生 */
  store_attr.getScope() instanceof Function and
  /* 由导入产生的变量必须具有较长的生命周期 */
  not im.getScope() instanceof Function and
  // 确保属性是存储操作
  store_attr.isStore() and
  // 确保属性对象指向导入的模块
  store_attr.getObject(name).pointsTo(m) and
  /* 导入不在修改所在的同一模块中。 */
  not im.getEnclosingModule() = store_attr.getScope().getEnclosingModule() and
  /* 修改不在测试中 */
  not store_attr.getScope().getScope*() instanceof TestScope
select im,
  "Importing the value of '" + name +
    "' from $@ means that any change made to $@ will be not be observed locally.", m,
  "module " + m.getName(), store_attr, m.getName() + "." + store_attr.getName()
