/**
 * @name Misnamed class
 * @description A class name that begins with a lowercase letter decreases readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// 定义一个谓词函数，用于判断类名是否以小写字母开头
predicate lower_case_class(Class c) {
  // 检查类名的第一个字符是否存在且不是大写字母
  exists(string first_char |
    first_char = c.getName().prefix(1) and // 获取类名的第一个字符
    not first_char = first_char.toUpperCase() // 判断第一个字符是否不是大写字母
  )
}

// 从所有类中选择满足条件的类
from Class c
where
  c.inSource() and // 类在源代码中存在
  lower_case_class(c) and // 类名以小写字母开头
  not exists(Class c1 |
    c1 != c and // 排除其他类
    c1.getLocation().getFile() = c.getLocation().getFile() and // 在同一文件中
    lower_case_class(c1) // 其他类也以小写字母开头
  )
select c, "Class names should start in uppercase." // 选择符合条件的类并给出提示信息
