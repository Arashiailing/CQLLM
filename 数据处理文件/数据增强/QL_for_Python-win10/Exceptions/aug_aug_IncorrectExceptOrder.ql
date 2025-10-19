/**
 * @name Unreachable 'except' block
 * @description Identifies situations where a specific exception handler is positioned after a general one,
 *              causing it to be unreachable because the general handler will always intercept the exception first.
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
ClassValue getHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// 检查两个异常处理块的顺序是否会导致后者不可达
predicate hasUnreachableExceptionHandler(ExceptStmt precedingHandler, ClassValue broaderExceptionType, 
                                        ExceptStmt subsequentHandler, ClassValue narrowerExceptionType) {
  exists(int precedingIndex, int subsequentIndex, Try tryStatement |
    // 两个异常处理块属于同一个 try 语句
    precedingHandler = tryStatement.getHandler(precedingIndex) and
    subsequentHandler = tryStatement.getHandler(subsequentIndex) and
    // 较早的异常处理块在较晚的之前
    precedingIndex < subsequentIndex and
    // 获取异常处理块对应的异常类型
    broaderExceptionType = getHandledExceptionType(precedingHandler) and
    narrowerExceptionType = getHandledExceptionType(subsequentHandler) and
    // 较早的异常处理块处理的是较晚的异常处理块所处理异常的父类
    broaderExceptionType = narrowerExceptionType.getASuperType()
  )
}

// 从所有异常处理块和对应的异常类型中查找不可达的异常处理块
from ExceptStmt precedingHandler, ClassValue broaderExceptionType, 
     ExceptStmt subsequentHandler, ClassValue narrowerExceptionType
// 检查是否存在顺序问题
where hasUnreachableExceptionHandler(precedingHandler, broaderExceptionType, subsequentHandler, narrowerExceptionType)
// 选择不可达的异常处理块并生成警告信息
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerExceptionType, narrowerExceptionType.getName(), precedingHandler, "except block", broaderExceptionType, broaderExceptionType.getName()