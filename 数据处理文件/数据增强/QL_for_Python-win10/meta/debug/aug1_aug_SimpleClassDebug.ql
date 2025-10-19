/**
 * 分析指定类名和文件路径的类层次结构
 * 包含目标类的父类、子类及目标类本身查询
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class cls) {
  // 验证类名是否匹配目标名称
  cls.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径
  // and cls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有父类（包括间接父类）
query predicate findSuperClasses(Class subCls, Class superClass) {
  isTargetClass(subCls) and
  superClass = getADirectSuperclass+(subCls)
}

// 查询目标类的所有子类（包括间接子类）
query predicate findSubClasses(Class superClass, Class subCls) {
  isTargetClass(superClass) and
  subCls = getADirectSubclass+(superClass)
}

// 选择所有符合条件的目标类
from Class targetClass
where isTargetClass(targetClass)
select targetClass