/**
 * 检索特定类名的类及其继承关系层次结构
 * 此查询识别指定名称的类，并分析其父类和子类的继承关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否符合目标类名条件的谓词
predicate matchesTargetClass(Class cls) {
  // 检查类名是否与目标名称匹配
  cls.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径
  // and cls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的继承关系（包括父类和子类）
query predicate getClassHierarchy(Class baseClass, Class derivedClass) {
  // 查找目标类的所有父类（包括间接父类）
  (
    matchesTargetClass(derivedClass) and
    baseClass = getADirectSuperclass+(derivedClass)
  )
  or
  // 查找目标类的所有子类（包括间接子类）
  (
    matchesTargetClass(baseClass) and
    derivedClass = getADirectSubclass+(baseClass)
  )
}

// 选择所有符合条件的目标类
from Class desiredClass
where matchesTargetClass(desiredClass)
select desiredClass