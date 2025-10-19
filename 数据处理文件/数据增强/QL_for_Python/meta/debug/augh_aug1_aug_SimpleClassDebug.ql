/**
 * 检索特定类名的类层次结构关系
 * 该查询用于识别目标类及其在继承体系中的位置，包括所有祖先类和后代类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为指定目标类的谓词
predicate matchesTargetClass(Class cls) {
  // 检查类名是否与预设目标名称匹配
  cls.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径
  // and cls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询类之间的继承关系
query predicate getClassHierarchy(Class baseClass, Class relatedClass, string relationType) {
  (
    // 查找目标类的所有祖先类（包括直接和间接父类）
    matchesTargetClass(baseClass) and
    relatedClass = getADirectSuperclass+(baseClass) and
    relationType = "superclass"
  )
  or
  (
    // 查找目标类的所有后代类（包括直接和间接子类）
    matchesTargetClass(relatedClass) and
    baseClass = getADirectSubclass+(relatedClass) and
    relationType = "subclass"
  )
}

// 检索所有符合条件的目标类
from Class desiredClass
where matchesTargetClass(desiredClass)
select desiredClass