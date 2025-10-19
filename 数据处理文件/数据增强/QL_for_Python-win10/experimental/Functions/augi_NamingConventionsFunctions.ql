/**
 * @name Misnamed function
 * @description Identifies functions with names starting with an uppercase letter, 
 *              which violates Python naming conventions and decreases code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @coding-standard Python PEP 8
 */

import python  // 导入Python库，用于分析Python代码

// 定义一个谓词函数，用于判断函数名是否以大写字母开头
predicate isFunctionNameCapitalized(Function targetFunction) {
  exists(string initialChar |
    initialChar = targetFunction.getName().prefix(1) and  // 获取函数名的第一个字符
    not initialChar = initialChar.toLowerCase()  // 判断第一个字符是否不是小写字母
  )
}

// 从所有函数中选择满足条件的函数
from Function targetFunction
where
  targetFunction.inSource() and  // 函数在源代码中存在
  isFunctionNameCapitalized(targetFunction) and  // 函数名以大写字母开头
  not exists(Function duplicateFunction |
    duplicateFunction != targetFunction and  // 排除同名的其他函数
    duplicateFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // 在同一文件中
    isFunctionNameCapitalized(duplicateFunction)  // 并且也以大写字母开头
  )
select targetFunction, "Function names should start in lowercase."  // 选择并报告这些函数，提示函数名应以小写字母开头