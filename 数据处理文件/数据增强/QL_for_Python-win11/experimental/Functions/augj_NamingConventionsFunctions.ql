/**
 * @name Misnamed function
 * @description Identifies functions whose names start with an uppercase letter, which violates Python naming conventions.
 *              Function names should start with a lowercase letter to improve code readability and maintainability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @coding-standards PEP8
 */

import python  // 导入Python库，用于分析Python代码

// 定义一个谓词函数，用于判断函数名是否以大写字母开头
predicate hasUppercaseStart(Function functionObj) {
  // 检查函数名的第一个字符是否不是小写字母
  not functionObj.getName().prefix(1).matches("[a-z]")
}

// 从所有函数中选择满足条件的函数
from Function functionObj
where
  functionObj.inSource() and  // 函数在源代码中存在
  hasUppercaseStart(functionObj) and  // 函数名以大写字母开头
  // 确保不是同一文件中多个同名函数之一（避免重复报告）
  not exists(Function otherFunction |
    otherFunction != functionObj and
    otherFunction.getLocation().getFile() = functionObj.getLocation().getFile() and
    hasUppercaseStart(otherFunction)
  )
select functionObj, "Function names should start in lowercase."  // 选择并报告这些函数，提示函数名应以小写字母开头