/**
 * @name Misnamed class
 * @description 类名以小写字母开头会降低可读性。
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// 判断类名是否以小写字母开头的谓词
predicate lower_case_class(Class cls) {
  // 检查类名的第一个字符是否不是大写字母
  exists(string initialChar |
    initialChar = cls.getName().prefix(1) and
    not initialChar = initialChar.toUpperCase()
  )
}

// 从所有类中选择满足条件的类
from Class cls
where
  cls.inSource() and // 类在源代码中存在
  lower_case_class(cls) and // 类名以小写字母开头
  not exists(Class otherClass |
    otherClass != cls and // 排除其他类
    otherClass.getLocation().getFile() = cls.getLocation().getFile() and // 在同一文件中
    lower_case_class(otherClass) // 其他类也以小写字母开头
  )
select cls, "Class names should start in uppercase." // 选择符合条件的类并给出提示信息