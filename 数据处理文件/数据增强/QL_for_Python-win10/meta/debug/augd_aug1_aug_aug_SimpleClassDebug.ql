/**
 * 探查特定类名的继承关系图谱
 * 此查询用于定位目标类及其在继承体系中的所有上级类和下级类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判定类是否属于分析焦点
predicate isTargetClass(Class focusClass) {
  // 核实类名是否匹配预定名称
  focusClass.getName() = "YourClassName"
  // 可选：核实类是否位于特定文件路径
  // and focusClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 定位目标类的所有上级类（包括直接和间接父类）
query predicate locateParentClasses(Class childClass, Class parentClass) {
  isTargetClass(childClass) and
  parentClass = getADirectSuperclass+(childClass)
}

// 定位目标类的所有下级类（包括直接和间接子类）
query predicate locateChildClasses(Class parentClass, Class childClass) {
  isTargetClass(parentClass) and
  childClass = getADirectSubclass+(parentClass)
}

// 选取所有符合分析目标的类
from Class targetCls
where isTargetClass(targetCls)
select targetCls