/**
 * 检查指定类名和文件路径的类层次结构
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class targetClass) {
  // 检查类名是否匹配目标名称
  targetClass.getName() = "YourClassName"
  // 可选：检查类是否位于特定文件路径
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的直接父类
query predicate findSuperClasses(Class subCls, Class superClass) {
  isTargetClass(subCls) and
  superClass = getADirectSuperclass+(subCls)
}

// 查询目标类的直接子类
query predicate findSubClasses(Class superClass, Class subCls) {
  isTargetClass(superClass) and
  subCls = getADirectSubclass+(superClass)
}

// 选择所有目标类
from Class targetClass
where isTargetClass(targetClass)
select targetClass