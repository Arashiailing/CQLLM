/**
 * 类继承层次结构分析器
 * 
 * 功能：
 * - 识别特定目标类
 * - 查找目标类的所有父类（包括直接和间接继承关系）
 * - 查找目标类的所有子类（包括直接和间接派生关系）
 * 
 * 使用方法：
 * - 修改 isTargetClass 谓词中的类名以指定目标类
 * - 可选：添加文件路径条件以进一步限定目标类
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 判断类是否为分析目标类
predicate isTargetClass(Class targetClass) {
  // 检查类名是否匹配预设目标
  targetClass.getName() = "YourClassName"
  // 可选条件：验证类是否位于特定文件路径
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 查询目标类的所有父类（包括直接和间接继承关系）
query predicate getSuperClasses(Class childClass, Class parentClass) {
  isTargetClass(childClass) and
  parentClass = getADirectSuperclass+(childClass)
}

// 查询目标类的所有子类（包括直接和间接派生关系）
query predicate getSubClasses(Class parentClass, Class childClass) {
  isTargetClass(parentClass) and
  childClass = getADirectSubclass+(parentClass)
}

// 主查询：查找并返回所有符合目标条件的类
from Class targetClass
where isTargetClass(targetClass)
select targetClass