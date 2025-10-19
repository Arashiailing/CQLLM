/**
 * @name Misnamed class
 * @description 检测类名是否以小写字母开头，这种情况会降低代码的可读性。
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// 定义谓词，检查类名是否以小写字母开头
predicate classNameStartsWithLowerCase(Class classObj) {
  // 获取类名的第一个字符，并检查其是否不是大写字母
  not classObj.getName().prefix(1) = classObj.getName().prefix(1).toUpperCase()
}

// 查找所有符合条件的类
from Class classObj
where 
  // 基本条件：类必须在源代码中定义
  classObj.inSource() and
  
  // 主要条件：类名必须以小写字母开头
  classNameStartsWithLowerCase(classObj) and
  
  // 附加条件：在同一文件中不能有其他类也是以小写字母开头
  not exists(Class anotherClass |
      anotherClass != classObj and
      anotherClass.getLocation().getFile() = classObj.getLocation().getFile() and
      classNameStartsWithLowerCase(anotherClass)
    )
select classObj, "Class names should start in uppercase."