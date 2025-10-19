/**
 * 检测指定类名及其继承关系中的完整类层次结构
 * 此查询用于识别目标类以及其在继承链中的所有父类和子类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为需要重点分析的目标类
predicate isTargetClass(Class focusedClass) {
  // 验证类名是否与预设目标名称相符
  focusedClass.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径中
  // and focusedClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的完整继承关系（包括所有祖先类和后代类）
query predicate findRelatedClasses(Class baseClass, Class relatedClass, string relationType) {
  (
    // 查找所有祖先类（直接和间接父类）
    isTargetClass(baseClass) and
    relatedClass = getADirectSuperclass+(baseClass) and
    relationType = "ancestor"
  )
  or
  (
    // 查找所有后代类（直接和间接子类）
    isTargetClass(baseClass) and
    relatedClass = getADirectSubclass+(baseClass) and
    relationType = "descendant"
  )
}

// 选择所有符合条件的目标类
from Class targetCls
where isTargetClass(targetCls)
select targetCls