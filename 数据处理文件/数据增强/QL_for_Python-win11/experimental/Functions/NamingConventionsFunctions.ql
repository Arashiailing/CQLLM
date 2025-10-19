/**
 * @name Misnamed function
 * @description A function name that begins with an uppercase letter decreases readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // 导入Python库，用于分析Python代码

// 定义一个谓词函数，用于判断函数名是否以大写字母开头
predicate upper_case_function(Function func) {
  exists(string first_char |
    first_char = func.getName().prefix(1) and  // 获取函数名的第一个字符
    not first_char = first_char.toLowerCase()  // 判断第一个字符是否不是小写字母
  )
}

// 从所有函数中选择满足条件的函数
from Function func
where
  func.inSource() and  // 函数在源代码中存在
  upper_case_function(func) and  // 函数名以大写字母开头
  not exists(Function func1 |
    func1 != func and  // 排除同名的其他函数
    func1.getLocation().getFile() = func.getLocation().getFile() and  // 在同一文件中
    upper_case_function(func1)  // 并且也以大写字母开头
  )
select func, "Function names should start in lowercase."  // 选择并报告这些函数，提示函数名应以小写字母开头
