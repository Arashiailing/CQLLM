/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are never executed because a more general
 *              exception handler precedes them in the same try-except structure, catching
 *              all exceptions before the more specific handler is reached.
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

/** 获取except子句处理的异常类 */
ClassValue extractHandledException(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

/** 检查后续异常处理器是否被前置的宽泛处理器遮蔽 */
predicate isShadowedExceptionHandler(ExceptStmt precedingHandler, ClassValue generalException, 
                                    ExceptStmt followingHandler, ClassValue specificException) {
  exists(int precedingIndex, int followingIndex, Try tryStatement |
    // 验证两个处理器属于同一try语句
    precedingHandler = tryStatement.getHandler(precedingIndex) and
    followingHandler = tryStatement.getHandler(followingIndex) and
    // 确保前置处理器在源码中先出现
    precedingIndex < followingIndex and
    // 提取两个处理器的异常类型
    generalException = extractHandledException(precedingHandler) and
    specificException = extractHandledException(followingHandler) and
    // 验证前置处理器捕获的是后续处理器异常的父类
    generalException = specificException.getASuperType()
  )
}

// 查询被遮蔽的不可达异常处理器
from ExceptStmt precedingHandler, ClassValue generalException, 
     ExceptStmt followingHandler, ClassValue specificException
where isShadowedExceptionHandler(precedingHandler, generalException, followingHandler, specificException)
select followingHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), precedingHandler, "except block", generalException, generalException.getName()