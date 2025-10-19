/**
 * 检测特定类名及文件路径的类继承关系
 * 本查询识别目标类及其在继承体系中的所有父类和子类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为目标类的谓词
predicate qualifiesAsTargetClass(Class targetClass) {
  // 验证类名是否匹配目标名称
  targetClass.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的完整父类链（包括直接和间接父类）
query predicate traceSuperClasses(Class childClass, Class parentClass) {
  qualifiesAsTargetClass(childClass) and
  parentClass = getADirectSuperclass+(childClass)
}

// 查询目标类的完整子类链（包括直接和间接子类）
query predicate traceSubClasses(Class parentClass, Class childClass) {
  qualifiesAsTargetClass(parentClass) and
  childClass = getADirectSubclass+(parentClass)
}

// 选择所有符合目标类定义的类
from Class targetClass
where qualifiesAsTargetClass(targetClass)
select targetClass