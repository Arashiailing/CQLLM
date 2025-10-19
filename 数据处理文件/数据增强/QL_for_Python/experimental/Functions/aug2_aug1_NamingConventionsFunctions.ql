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

// 辅助谓词：判断函数名是否以大写字母开头
predicate startsWithUppercase(Function func) {
  exists(string firstChar |
    firstChar = func.getName().prefix(1) and  // 提取函数名的首字符
    not firstChar = firstChar.toLowerCase()  // 验证首字符不是小写字母
  )
}

// 查询违反命名规范的函数
from Function funcWithIssue
where
  // 确保函数定义在源代码中且名称以大写字母开头
  funcWithIssue.inSource() and
  startsWithUppercase(funcWithIssue) and
  // 确保同一文件中没有其他函数也以大写字母开头
  not exists(Function otherFunc |
    otherFunc != funcWithIssue and  // 排除当前函数本身
    otherFunc.getLocation().getFile() = funcWithIssue.getLocation().getFile() and  // 确保在同一文件中
    startsWithUppercase(otherFunc)  // 其他函数也以大写字母开头
  )
select funcWithIssue, "Function names should start in lowercase."  // 输出违反命名约定的函数