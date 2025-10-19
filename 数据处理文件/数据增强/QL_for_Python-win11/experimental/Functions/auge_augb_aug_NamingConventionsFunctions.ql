/**
 * @name Misnamed function
 * @description 检测以大写字母开头且在文件中唯一的函数，这违反了Python命名约定。
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// 判断函数名首字母是否为大写的谓词
predicate hasCapitalInitial(Function functionObj) {
  // 提取函数名的首字符并验证其是否为大写
  exists(string initialChar |
    initialChar = functionObj.getName().prefix(1) and
    initialChar != initialChar.toLowerCase()
  )
}

// 查找所有违反命名约定的函数
from Function functionObj
where
  // 确保函数定义在源代码中
  functionObj.inSource() and
  // 检查函数名是否以大写字母开头
  hasCapitalInitial(functionObj) and
  // 确保该函数是文件中唯一一个以大写字母开头的函数
  not exists(Function otherFunction |
    // 排除当前函数本身
    otherFunction != functionObj and
    // 确保在同一文件中
    otherFunction.getLocation().getFile() = functionObj.getLocation().getFile() and
    // 其他函数也以大写字母开头
    hasCapitalInitial(otherFunction)
  )
select functionObj, "Function names should start in lowercase."