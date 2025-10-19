/**
 * @name Misnamed class
 * @description A class name that begins with a lowercase letter decreases readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// 判断类名是否以小写字母开头
predicate hasLowercaseName(Class cls) {
  // 获取类名的首字符并检查其是否为大写字母
  exists(string initialChar |
    initialChar = cls.getName().prefix(1) and
    not initialChar = initialChar.toUpperCase()
  )
}

// 查找源代码中类名以小写字母开头的类，且是所在文件中唯一一个此类
from Class cls
where
  cls.inSource() and // 确保类在源代码中存在
  hasLowercaseName(cls) and // 检查类名是否以小写字母开头
  not exists(Class otherCls |
    otherCls != cls and // 排除当前类
    otherCls.getLocation().getFile() = cls.getLocation().getFile() and // 确保在同一文件中
    hasLowercaseName(otherCls) // 检查其他类是否也以小写字母开头
  )
select cls, "Class names should start in uppercase." // 输出结果和提示信息