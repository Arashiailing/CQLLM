/**
 * @name Misnamed function
 * @description 一个以大写字母开头的函数名会降低代码可读性。
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// 定义一个谓词，用于判断函数名是否以大写字母开头
predicate isUpperCaseFunction(Function functionToCheck) {
  exists(string initialChar |
    initialChar = functionToCheck.getName().prefix(1) and  // 获取函数名的第一个字符
    not initialChar = initialChar.toLowerCase()  // 判断第一个字符是否不是小写字母
  )
}

// 从所有函数中选择满足条件的函数
from Function functionToCheck
where
  functionToCheck.inSource() and  // 函数在源代码中存在
  isUpperCaseFunction(functionToCheck) and  // 函数名以大写字母开头
  not exists(Function otherFunction |
    otherFunction != functionToCheck and  // 排除同名的其他函数
    otherFunction.getLocation().getFile() = functionToCheck.getLocation().getFile() and  // 在同一文件中
    isUpperCaseFunction(otherFunction)  // 并且也以大写字母开头
  )
select functionToCheck, "Function names should start in lowercase."  // 选择并报告这些函数，提示函数名应以小写字母开头