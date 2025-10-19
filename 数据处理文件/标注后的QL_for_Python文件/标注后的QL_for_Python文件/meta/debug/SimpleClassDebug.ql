/**
 * 填写您的类名和文件路径，以检查类层次结构。
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 定义一个谓词函数，用于判断一个类是否是我们感兴趣的类
predicate interestingClass(Class cls) {
  // 检查类的名称是否为 "YourClassName"
  cls.getName() = "YourClassName"
  // 并且可以添加以下代码来检查类的位置是否匹配特定文件路径
  // and cls.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
}

// 定义一个查询谓词，用于查找某个类的直接父类
query predicate superClasses(Class cls, Class super_) {
  // 检查类是否是我们感兴趣的类
  interestingClass(cls) and
  // 获取该类的直接父类
  super_ = getADirectSuperclass+(cls)
}

// 定义一个查询谓词，用于查找某个类的直接子类
query predicate subClasses(Class cls, Class super_) {
  // 检查类是否是我们感兴趣的类
  interestingClass(cls) and
  // 获取该类的直接子类
  super_ = getADirectSubclass+(cls)
}

// 从所有类中选择我们感兴趣的类
from Class cls
where interestingClass(cls)
select cls
