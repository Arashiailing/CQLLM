/**
 * 分析目标类及其继承层次结构
 * 该查询识别指定名称的类，并分别检索其所有父类和子类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class targetClass) {
  // 验证类名是否匹配目标名称
  targetClass.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的完整继承链（所有父类）
query predicate findSuperClasses(Class subClass, Class ancestorClass) {
  isTargetClass(subClass) and
  ancestorClass = getADirectSuperclass+(subClass)
}

// 查询目标类的完整派生链（所有子类）
query predicate findSubClasses(Class baseClass, Class derivedClass) {
  isTargetClass(baseClass) and
  derivedClass = getADirectSubclass+(baseClass)
}

// 选择所有符合目标类定义的类
from Class cls
where isTargetClass(cls)
select cls