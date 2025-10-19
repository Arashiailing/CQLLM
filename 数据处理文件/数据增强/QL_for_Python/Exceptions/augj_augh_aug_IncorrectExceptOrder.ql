/**
 * @name Unreachable 'except' block
 * @description Identifies exception handling blocks that will never execute because a more general
 *              exception handler precedes a more specific one in the same try statement.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-561
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-except
 */

import python

from ExceptStmt unreachableHandler, ClassValue specificExceptionType, 
     ExceptStmt precedingExceptionHandler, ClassValue generalExceptionType
where 
  exists(int precedingIndex, int subsequentIndex, Try tryStatement |
    // 确保两个异常处理块属于同一个try语句
    precedingExceptionHandler = tryStatement.getHandler(precedingIndex) and
    unreachableHandler = tryStatement.getHandler(subsequentIndex) and
    // 验证处理块顺序（先出现的在前）
    precedingIndex < subsequentIndex and
    // 获取异常类型并建立类型关系
    precedingExceptionHandler.getType().pointsTo(generalExceptionType) and
    unreachableHandler.getType().pointsTo(specificExceptionType) and
    // 检查异常类型继承关系（父类异常处理在前导致子类处理不可达）
    generalExceptionType = specificExceptionType.getASuperType()
  )
select unreachableHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificExceptionType, specificExceptionType.getName(), precedingExceptionHandler, "except block", generalExceptionType, generalExceptionType.getName()