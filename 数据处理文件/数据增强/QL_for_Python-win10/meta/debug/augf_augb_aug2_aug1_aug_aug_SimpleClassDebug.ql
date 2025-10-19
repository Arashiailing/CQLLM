/**
 * 类继承层次结构关系分析
 * 本查询用于识别特定类及其在继承体系中的所有父类和子类关系
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

/**
 * 判断类是否为分析目标类
 * @param analysisCls 要分析的类对象
 */
predicate isTargetClass(Class analysisCls) {
  // 检查类名是否匹配预设目标
  analysisCls.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and analysisCls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

/**
 * 查询目标类的所有父类（包括直接和间接继承关系）
 * @param childCls 子类
 * @param parentCls 父类
 */
query predicate getParentClasses(Class childCls, Class parentCls) {
  isTargetClass(childCls) and
  parentCls = getADirectSuperclass+(childCls)
}

/**
 * 查询目标类的所有子类（包括直接和间接派生关系）
 * @param parentCls 父类
 * @param childCls 子类
 */
query predicate getChildClasses(Class parentCls, Class childCls) {
  isTargetClass(parentCls) and
  childCls = getADirectSubclass+(parentCls)
}

// 主查询：返回所有符合目标条件的类
from Class targetCls
where isTargetClass(targetCls)
select targetCls