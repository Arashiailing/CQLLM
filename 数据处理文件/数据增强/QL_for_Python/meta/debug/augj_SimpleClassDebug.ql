/**
 * 检查指定类及其层次结构关系
 * - 目标类：通过名称和路径匹配
 * - 分析内容：类的父类和子类继承关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断是否为目标分析类
predicate isTargetClass(Class targetCls) {
  // 类名精确匹配
  targetCls.getName() = "YourClassName"
  // 可选：添加路径约束（取消注释启用）
  // and targetCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有父类（包括间接继承）
query predicate parentClasses(Class targetCls, Class parentCls) {
  isTargetClass(targetCls) and
  parentCls = getADirectSuperclass+(targetCls)
}

// 查询目标类的所有子类（包括间接继承）
query predicate childClasses(Class targetCls, Class childCls) {
  isTargetClass(targetCls) and
  childCls = getADirectSubclass+(targetCls)
}

// 输出所有匹配的目标类
from Class targetCls
where isTargetClass(targetCls)
select targetCls