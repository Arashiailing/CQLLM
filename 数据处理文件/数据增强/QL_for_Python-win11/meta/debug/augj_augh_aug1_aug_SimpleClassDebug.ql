/**
 * 检索指定目标类的类层次结构关系
 * 该查询用于识别目标类及其在继承体系中的位置，包括所有祖先类和后代类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate isTargetClass(Class cls) {
  // 验证类名是否与预设目标名称匹配
  cls.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径
  // and cls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询类之间的继承关系
query predicate getClassHierarchy(Class targetClass, Class relativeClass, string relationType) {
  (
    // 查找目标类的所有后代类（包括直接和间接子类）
    isTargetClass(relativeClass) and
    targetClass = getADirectSubclass+(relativeClass) and
    relationType = "subclass"
  )
  or
  (
    // 查找目标类的所有祖先类（包括直接和间接父类）
    isTargetClass(targetClass) and
    relativeClass = getADirectSuperclass+(targetClass) and
    relationType = "superclass"
  )
}

// 检索所有符合条件的目标类
from Class targetClass
where isTargetClass(targetClass)
select targetClass