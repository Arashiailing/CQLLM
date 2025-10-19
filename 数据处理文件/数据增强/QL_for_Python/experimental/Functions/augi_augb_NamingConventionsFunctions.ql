/**
 * @name Function name starts with uppercase letter
 * @description Detects Python functions that begin with a capital letter, 
 *              which is against PEP 8 naming conventions and may reduce code clarity.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // 导入Python库，用于分析Python代码

// 主查询：识别所有违反命名规范的函数
from Function func
where
  // 确保函数存在于源代码中
  func.inSource() and
  
  // 检查函数名是否以大写字母开头
  exists(string firstChar |
    firstChar = func.getName().prefix(1) and  // 提取函数名的首字符
    not firstChar = firstChar.toLowerCase()  // 检查首字符是否为大写字母
  ) and
  
  // 排除同一文件中的同名函数（避免重复报告）
  not exists(Function duplicateFunc |
    duplicateFunc != func and  // 确保不是同一个函数
    duplicateFunc.getLocation().getFile() = func.getLocation().getFile() and  // 确保在同一文件中
    exists(string firstChar |
      firstChar = duplicateFunc.getName().prefix(1) and  // 提取函数名的首字符
      not firstChar = firstChar.toLowerCase()  // 检查首字符是否为大写字母
    )
  )
select func, "Function names should start in lowercase."  // 输出结果并给出改进建议