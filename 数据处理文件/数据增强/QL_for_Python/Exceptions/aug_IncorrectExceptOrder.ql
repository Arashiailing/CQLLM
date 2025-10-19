/**
 * @name Unreachable 'except' block
 * @description Handling general exceptions before specific exceptions means that the specific
 *              handlers are never executed.
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

// 获取异常处理块对应的异常类型
ClassValue getExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// 检测异常处理顺序问题：当父类异常处理块位于子类异常处理块之前时
predicate hasIncorrectExceptOrder(ExceptStmt earlierHandler, ClassValue broaderException, 
                                 ExceptStmt laterHandler, ClassValue specificException) {
  exists(int earlierIndex, int laterIndex, Try tryStmt |
    // 确定两个异常处理块属于同一个try语句
    earlierHandler = tryStmt.getHandler(earlierIndex) and
    laterHandler = tryStmt.getHandler(laterIndex) and
    // 验证处理块顺序（先出现的在前）
    earlierIndex < laterIndex and
    // 获取异常类型
    broaderException = getExceptionClass(earlierHandler) and
    specificException = getExceptionClass(laterHandler) and
    // 检查异常类型继承关系（父类异常处理在前）
    broaderException = specificException.getASuperType()
  )
}

// 查找所有不可达的异常处理块
from ExceptStmt laterHandler, ClassValue specificException, 
     ExceptStmt earlierHandler, ClassValue broaderException
where hasIncorrectExceptOrder(earlierHandler, broaderException, 
                             laterHandler, specificException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()