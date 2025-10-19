/**
 * @name Function with Uppercase Initial
 * @description Identifies functions whose names start with an uppercase letter, which violates Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @coding-standard Python PEP8 naming conventions
 */

import python  // 导入Python库，用于分析Python代码

// 定义辅助谓词，检查函数名是否以大写字母开头
predicate hasUppercaseInitial(Function functionObj) {
  exists(string initialChar |
    initialChar = functionObj.getName().prefix(1) and  // 获取函数名的首字符
    not initialChar = initialChar.toLowerCase()  // 检查首字符是否不是小写字母
  )
}

// 选择满足条件的函数
from Function targetFunction
where
  targetFunction.inSource() and  // 确保函数在源代码中定义
  hasUppercaseInitial(targetFunction) and  // 函数名以大写字母开头
  not exists(Function conflictingFunction |
    conflictingFunction != targetFunction and  // 排除函数本身
    conflictingFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // 确保在同一文件中
    hasUppercaseInitial(conflictingFunction)  // 其他函数也以大写字母开头
  )
select targetFunction, "Function names should start in lowercase."  // 报告违反命名约定的函数