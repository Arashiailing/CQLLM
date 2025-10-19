/**
 * 类继承层次结构分析器
 * 本查询用于识别特定名称的类，并分别检索其完整的父类继承链和子类派生链
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为指定目标类的谓词
predicate isDesiredClass(Class desiredClass) {
  // 验证类名是否匹配预设的目标名称
  desiredClass.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径
  // and desiredClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的完整继承层次（所有父类）
query predicate retrieveSuperClasses(Class childClass, Class parentClass) {
  isDesiredClass(childClass) and
  parentClass = getADirectSuperclass+(childClass)
}

// 查询目标类的完整派生层次（所有子类）
query predicate retrieveSubClasses(Class rootClass, Class offspringClass) {
  isDesiredClass(rootClass) and
  offspringClass = getADirectSubclass+(rootClass)
}

// 选择所有符合目标类定义的类实例
from Class targetCls
where isDesiredClass(targetCls)
select targetCls