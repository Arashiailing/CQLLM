/**
 * @name Misnamed class
 * @description Identifies classes with names that start with a lowercase letter, which violates Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 * @convention PEP8
 */

import python

// 查找所有类名以小写字母开头的类，但仅当该类是其所在文件中唯一一个此类时报告
from Class cls
where
  cls.inSource() and // 确保类存在于源代码中
  
  // 检查类名是否以小写字母开头
  exists(string initialChar |
    initialChar = cls.getName().prefix(1) and
    not initialChar = initialChar.toUpperCase()
  ) and
  
  // 确保在同一文件中没有其他类名也以小写字母开头
  not exists(Class otherCls |
    otherCls != cls and // 排除当前类
    otherCls.getLocation().getFile() = cls.getLocation().getFile() and // 确保在同一文件中
    exists(string otherInitialChar |
      otherInitialChar = otherCls.getName().prefix(1) and
      not otherInitialChar = otherInitialChar.toUpperCase()
    )
  )
select cls, "Class names should start in uppercase."