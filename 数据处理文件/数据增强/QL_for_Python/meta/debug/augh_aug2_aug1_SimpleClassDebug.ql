/**
 * 分析目标类及其继承层次结构
 * 通过精确类名匹配目标类，支持通过文件路径进行范围限定
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 目标类识别谓词
predicate isTargetClass(Class targetClass) {
  // 精确匹配类名
  targetClass.getName() = "YourClassName"
  // 可选范围限定：取消注释以启用文件路径过滤
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的直接父类
query predicate findSuperClass(Class target, Class superClass) {
  isTargetClass(target) and
  superClass = getADirectSuperclass+(target)
}

// 查询目标类的直接子类
query predicate findSubClass(Class target, Class subClass) {
  isTargetClass(target) and
  subClass = getADirectSubclass+(target)
}

// 输出所有匹配的目标类
from Class target
where isTargetClass(target)
select target