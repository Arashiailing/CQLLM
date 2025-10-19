/**
 * @name 检索指定名称的Python类
 * @description 此查询用于定位具有特定名称("YourClassName")的Python类定义
 *              可根据需要取消注释路径验证条件来限定搜索范围
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 查找所有符合条件的类定义
from Class matchedClass
where 
  // 确保类名与目标名称完全匹配
  matchedClass.getName() = "YourClassName"
  // 可选条件：限制类必须位于特定文件路径中
  // and matchedClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
select matchedClass