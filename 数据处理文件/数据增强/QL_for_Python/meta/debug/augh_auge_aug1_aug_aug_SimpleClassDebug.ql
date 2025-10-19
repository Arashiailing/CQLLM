/**
 * 识别特定名称的目标类
 * 此查询定位名为"YourClassName"的类，可扩展为包含路径验证
 */

import python
import semmle.python.dataflow.new.internal.DataFlowPublic
import semmle.python.dataflow.new.internal.DataFlowPrivate

// 检索符合名称条件的类定义
from Class targetClass
where 
  // 验证类名与预设目标匹配
  targetClass.getName() = "YourClassName"
  // 可选：验证类是否位于特定文件路径中
  // and targetClass.getLocation().getFile().getAbsolutePath().matches("%/folder/file.py")
select targetClass