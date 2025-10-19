/**
 * 识别特定类名和文件路径的类继承关系
 * 该查询用于定位目标类及其继承体系中的直接父类和子类
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

// 查询目标类的直接父类（包括间接父类）
query predicate findSuperClasses(Class derivedClass, Class baseClass) {
  isTargetClass(derivedClass) and
  baseClass = getADirectSuperclass+(derivedClass)
}

// 查询目标类的直接子类（包括间接子类）
query predicate findSubClasses(Class baseClass, Class derivedClass) {
  isTargetClass(baseClass) and
  derivedClass = getADirectSubclass+(baseClass)
}

// 选择所有符合目标条件的类
from Class clsOfInterest
where isTargetClass(clsOfInterest)
select clsOfInterest