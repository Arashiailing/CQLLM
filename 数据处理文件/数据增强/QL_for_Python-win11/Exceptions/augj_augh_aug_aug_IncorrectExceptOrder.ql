/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that become unreachable due to being positioned 
 *              after a more general handler that catches the same exception type first.
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

// 获取异常处理器处理的异常类型
ClassValue getHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// 判断异常处理器是否因前置处理器的存在而不可达
predicate hasUnreachableExceptionHandler(ExceptStmt precedingHandler, ClassValue superType, 
                                        ExceptStmt subsequentHandler, ClassValue subType) {
  exists(int precedingIndex, int subsequentIndex, Try tryBlock |
    // 确保两个处理器属于同一个try语句
    precedingHandler = tryBlock.getHandler(precedingIndex) and
    subsequentHandler = tryBlock.getHandler(subsequentIndex) and
    // 验证处理器顺序
    precedingIndex < subsequentIndex and
    // 获取两个处理器处理的异常类型
    superType = getHandledExceptionType(precedingHandler) and
    subType = getHandledExceptionType(subsequentHandler) and
    // 检查类型继承关系
    superType = subType.getASuperType()
  )
}

// 查询不可达的异常处理器及其相关信息
from ExceptStmt precedingHandler, ClassValue superType, 
     ExceptStmt subsequentHandler, ClassValue subType
where hasUnreachableExceptionHandler(precedingHandler, superType, subsequentHandler, subType)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  subType, subType.getName(), precedingHandler, "except block", superType, superType.getName()