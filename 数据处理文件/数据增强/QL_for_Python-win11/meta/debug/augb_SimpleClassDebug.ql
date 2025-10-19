/**
 * 检查指定类名和文件路径的类层次结构
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 定义谓词：判断类是否为目标类（名称匹配且路径可选匹配）
predicate isTargetClass(Class targetClass) {
  // 检查类名是否为指定名称
  targetClass.getName() = "YourClassName"
  // 可选：检查类所在文件路径（取消注释以启用路径匹配）
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询谓词：查找目标类的所有祖先类（传递闭包）
query predicate ancestorClasses(Class targetClass, Class ancestorClass) {
  // 验证目标类
  isTargetClass(targetClass) and
  // 获取所有祖先类（包括间接继承）
  ancestorClass = getADirectSuperclass+(targetClass)
}

// 查询谓词：查找目标类的所有后代类（传递闭包）
query predicate descendantClasses(Class targetClass, Class descendantClass) {
  // 验证目标类
  isTargetClass(targetClass) and
  // 获取所有后代类（包括间接继承）
  descendantClass = getADirectSubclass+(targetClass)
}

// 主查询：选择所有目标类
from Class cls
where isTargetClass(cls)
select cls