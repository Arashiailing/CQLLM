/**
 * @name Misnamed function
 * @description 一个以大写字母开头的函数名会降低代码可读性。
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// 检查函数名是否以大写字母开头的谓词
predicate startsWithUpperCase(Function func) {
  exists(string firstLetter |
    firstLetter = func.getName().prefix(1) and  // 提取函数名的首字母
    not firstLetter = firstLetter.toLowerCase()  // 判断首字母是否不是小写形式
  )
}

// 查找所有以大写字母开头且在文件中唯一的函数
from Function func
where
  func.inSource() and  // 确保函数存在于源代码中
  startsWithUpperCase(func) and  // 函数名以大写字母开头
  not exists(Function anotherFunc |
    anotherFunc != func and  // 排除当前函数本身
    anotherFunc.getLocation().getFile() = func.getLocation().getFile() and  // 确保在同一文件中
    startsWithUpperCase(anotherFunc)  // 其他函数也以大写字母开头
  )
select func, "Function names should start in lowercase."  // 报告这些函数，提示函数名应以小写开头