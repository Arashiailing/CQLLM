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

// 辅助谓词：获取异常处理块（except语句）所处理的异常类型
ClassValue getExceptionClass(ExceptStmt exceptionHandler) { 
  // 从异常处理块中提取类型信息，并获取其指向的类值
  exceptionHandler.getType().pointsTo(result) 
}

// 检测异常处理顺序问题的谓词：当父类异常处理块位于子类异常处理块之前时
predicate hasIncorrectExceptOrder(ExceptStmt precedingHandler, ClassValue generalException, 
                                 ExceptStmt subsequentHandler, ClassValue particularException) {
  exists(int precedingIndex, int subsequentIndex, Try tryStatement |
    // 确保两个异常处理块属于同一个try语句
    precedingHandler = tryStatement.getHandler(precedingIndex) and
    subsequentHandler = tryStatement.getHandler(subsequentIndex) and
    // 验证处理块在代码中的顺序（先出现的在前）
    precedingIndex < subsequentIndex and
    // 获取两个异常处理块分别处理的异常类型
    generalException = getExceptionClass(precedingHandler) and
    particularException = getExceptionClass(subsequentHandler) and
    // 检查异常类型之间的继承关系（确认前一个处理的是更一般的异常）
    generalException = particularException.getASuperType()
  )
}

// 主查询：查找所有不可达的异常处理块
from ExceptStmt subsequentHandler, ClassValue particularException, 
     ExceptStmt precedingHandler, ClassValue generalException
where hasIncorrectExceptOrder(precedingHandler, generalException, 
                             subsequentHandler, particularException)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  particularException, particularException.getName(), precedingHandler, "except block", generalException, generalException.getName()