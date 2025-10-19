/**
 * @name Misnamed function
 * @description 检测函数名以大写字母开头的情况，这违反了Python命名约定并降低代码可读性。
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

/**
 * 判断函数名是否以大写字母开头。
 * 通过提取函数名的首字母并检查其是否不等于小写形式来确定。
 */
predicate hasCapitalizedName(Function targetFunction) {
  exists(string initialChar |
    initialChar = targetFunction.getName().prefix(1) and  // 获取函数名的首字符
    not initialChar = initialChar.toLowerCase()  // 验证首字符是否为大写
  )
}

// 查找所有以大写字母开头且在文件中唯一的函数
from Function targetFunction
where
  targetFunction.inSource() and  // 确保函数存在于源代码中
  hasCapitalizedName(targetFunction) and  // 函数名以大写字母开头
  not exists(Function otherFunction |
    otherFunction != targetFunction and  // 排除当前函数本身
    otherFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // 确保在同一文件中
    hasCapitalizedName(otherFunction)  // 其他函数也以大写字母开头
  )
select targetFunction, "Function names should start in lowercase."  // 报告这些函数，提示函数名应以小写开头