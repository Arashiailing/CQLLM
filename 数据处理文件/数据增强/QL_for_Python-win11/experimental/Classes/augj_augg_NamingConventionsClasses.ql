/**
 * @name Misnamed class
 * @description A class name that begins with a lowercase letter decreases readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// 检查类名是否以小写字母开头
predicate isClassNamedWithLowercase(Class targetClass) {
  // 提取类名的首字母并验证其是否为小写
  exists(string firstChar |
    firstChar = targetClass.getName().prefix(1) and
    not firstChar = firstChar.toUpperCase()
  )
}

// 查找源代码中类名以小写字母开头的类，且是所在文件中唯一一个此类
from Class targetClass
where
  targetClass.inSource() and // 确保类在源代码中定义
  isClassNamedWithLowercase(targetClass) and // 检查类名是否以小写字母开头
  // 确保在同一文件中没有其他类也以小写字母开头
  not exists(Class siblingClass |
    siblingClass != targetClass and // 排除当前类
    siblingClass.getLocation().getFile() = targetClass.getLocation().getFile() and // 确保在同一文件中
    isClassNamedWithLowercase(siblingClass) // 检查其他类是否也以小写字母开头
  )
select targetClass, "Class names should start in uppercase." // 输出结果和提示信息