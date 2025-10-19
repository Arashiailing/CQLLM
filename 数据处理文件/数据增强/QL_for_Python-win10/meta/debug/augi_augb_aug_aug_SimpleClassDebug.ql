/**
 * 类继承层次结构分析器
 * 本查询用于定位特定类名的目标类，并分析其完整的继承体系，包括所有父类和子类关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判定类是否为分析目标的谓词函数
predicate isFocusClass(Class focusClass) {
  // 验证类名是否符合预定义目标
  focusClass.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and focusClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 检索目标类的完整继承链（所有父类）
query predicate getParentClasses(Class childClass, Class parentClass) {
  isFocusClass(childClass) and
  parentClass = getADirectSuperclass+(childClass)
}

// 检索目标类的完整派生链（所有子类）
query predicate getChildClasses(Class rootClass, Class descendantClass) {
  isFocusClass(rootClass) and
  descendantClass = getADirectSubclass+(rootClass)
}

// 选择所有符合目标类定义的类实例
from Class targetCls
where isFocusClass(targetCls)
select targetCls