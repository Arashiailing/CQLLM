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

/**
 * 获取指定异常处理块所处理的异常类型。
 * @param handler - 要分析的异常处理块
 * @return - 该异常处理块处理的异常类型
 */
ClassValue except_class(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

/**
 * 判断两个异常处理块的顺序是否会导致后一个处理块不可达。
 * 当一个处理更一般异常的块位于处理更特定异常的块之前时，会导致后者不可达。
 * 
 * @param firstHandler - 先执行的异常处理块
 * @param firstType - 先执行的异常处理块处理的异常类型
 * @param secondHandler - 后执行的异常处理块
 * @param secondType - 后执行的异常处理块处理的异常类型
 */
predicate incorrect_except_order(ExceptStmt firstHandler, ClassValue firstType, 
                                ExceptStmt secondHandler, ClassValue secondType) {
  exists(int firstIdx, int secondIdx, Try tryStmt |
    // 确定两个异常处理块属于同一个 try 语句
    firstHandler = tryStmt.getHandler(firstIdx) and
    secondHandler = tryStmt.getHandler(secondIdx) and
    
    // 确保先执行的异常处理块确实位于后执行的异常处理块之前
    firstIdx < secondIdx and
    
    // 获取两个异常处理块各自处理的异常类型
    firstType = except_class(firstHandler) and
    secondType = except_class(secondHandler) and
    
    // 检查先执行的异常处理块是否处理后执行的异常处理块的父类或接口
    // 如果是，则后执行的异常处理块将永远不会被执行
    firstType = secondType.getASuperType()
  )
}

// 查找所有不可达的异常处理块
from ExceptStmt firstHandler, ClassValue firstType, 
     ExceptStmt secondHandler, ClassValue secondType
where incorrect_except_order(firstHandler, firstType, secondHandler, secondType)
select secondHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  secondType, secondType.getName(), firstHandler, "except block", 
  firstType, firstType.getName()