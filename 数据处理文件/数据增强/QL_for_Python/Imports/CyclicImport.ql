/**
 * @name Cyclic import
 * @description 模块形成导入循环的一部分，从而间接地导入自身。
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/cyclic-import
 */

// 导入Python库和自定义的Cyclic库
import python
import Cyclic

// 定义查询，查找所有形成导入循环的模块
from ModuleValue m1, ModuleValue m2, Stmt imp
where
  // 获取包含导入语句的模块m1
  imp.getEnclosingModule() = m1.getScope() and
  // 获取被导入的模块m2
  stmt_imports(imp) = m2 and
  // 检查m1和m2之间是否存在循环导入
  circular_import(m1, m2) and
  // 确保m1和m2不是同一个模块
  m1 != m2 and
  // 排除由ModuleLevelCyclicImport标记的循环导入
  not failing_import_due_to_cycle(m2, m1, _, _, _, _) and
  // 排除在`if __name__ == "__main__"`块中的导入
  not exists(If i | i.isNameEqMain() and i.contains(imp))
select imp, "Import of module $@ begins an import cycle.", m2, m2.getName()
