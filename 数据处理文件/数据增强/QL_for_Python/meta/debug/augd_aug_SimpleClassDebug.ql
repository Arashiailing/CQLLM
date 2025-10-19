/**
 * 检查特定类名的类层次结构关系
 * 包括目标类本身、其所有父类和子类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 查询目标类及其直接父类（递归获取所有祖先类）
query predicate findSuperClasses(Class childClass, Class parentClass) {
  // 筛选目标类：类名匹配指定名称
  childClass.getName() = "YourClassName"
  // 可选：限制类所在文件路径（取消注释以启用）
  // and childClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
  and
  // 递归获取所有直接父类
  parentClass = getADirectSuperclass+(childClass)
}

// 查询目标类及其直接子类（递归获取所有后代类）
query predicate findSubClasses(Class parentClass, Class childClass) {
  // 筛选目标类：类名匹配指定名称
  parentClass.getName() = "YourClassName"
  // 可选：限制类所在文件路径（取消注释以启用）
  // and parentClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
  and
  // 递归获取所有直接子类
  childClass = getADirectSubclass+(parentClass)
}

// 选择所有匹配目标名称的类
from Class targetCls
where 
  // 筛选条件：类名匹配指定名称
  targetCls.getName() = "YourClassName"
  // 可选：限制类所在文件路径（取消注释以启用）
  // and targetCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
select targetCls