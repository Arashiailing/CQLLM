/**
 * 检测类继承结构中的层次关系
 * 此查询旨在定位指定类及其在整个继承体系中的上下级类关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 确定类是否属于分析目标
predicate isTargetClass(Class focusCls) {
  // 验证类名是否符合预定义目标
  focusCls.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and focusCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 识别目标类的所有上级类（包括直接和间接继承关系）
query predicate getParentClasses(Class childCls, Class parentCls) {
  isTargetClass(childCls) and
  parentCls = getADirectSuperclass+(childCls)
}

// 识别目标类的所有下级类（包括直接和间接派生关系）
query predicate getChildClasses(Class parentCls, Class childCls) {
  isTargetClass(parentCls) and
  childCls = getADirectSubclass+(parentCls)
}

// 筛选并返回所有符合目标条件的类
from Class focusCls
where isTargetClass(focusCls)
select focusCls