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
 * 获取异常处理块对应的异常类型。
 * @param exceptStmt - 异常处理块
 * @return - 异常类型
 */
ClassValue getExceptionClass(ExceptStmt exceptStmt) { 
  exceptStmt.getType().pointsTo(result) 
}

/**
 * 判断两个异常处理块的顺序是否会导致后面的块不可达。
 * 当一个处理一般异常的块位于处理特定异常的块之前时，后面的块将永远不会被执行。
 * @param earlierExcept - 先执行的异常处理块
 * @param generalExceptClass - 先执行的异常处理块处理的异常类型
 * @param laterExcept - 后执行的异常处理块
 * @param specificExceptClass - 后执行的异常处理块处理的异常类型
 */
predicate hasUnreachableExceptBlock(ExceptStmt earlierExcept, ClassValue generalExceptClass, 
                                   ExceptStmt laterExcept, ClassValue specificExceptClass) {
  exists(int earlierIndex, int laterIndex, Try tryStmt |
    // earlierExcept 是 tryStmt 的第 earlierIndex 个异常处理块
    earlierExcept = tryStmt.getHandler(earlierIndex) and
    // laterExcept 是 tryStmt 的第 laterIndex 个异常处理块
    laterExcept = tryStmt.getHandler(laterIndex) and
    // 确保 earlierExcept 在 laterExcept 之前
    earlierIndex < laterIndex and
    // 获取 earlierExcept 的异常类型
    generalExceptClass = getExceptionClass(earlierExcept) and
    // 获取 laterExcept 的异常类型
    specificExceptClass = getExceptionClass(laterExcept) and
    // 检查 generalExceptClass 是 specificExceptClass 的父类或接口
    generalExceptClass = specificExceptClass.getASuperType()
  )
}

// 从所有异常处理块中筛选出存在不可达情况的组合
from ExceptStmt earlierExcept, ClassValue generalExceptClass, 
     ExceptStmt laterExcept, ClassValue specificExceptClass
// 条件是这些数据满足 hasUnreachableExceptBlock 谓词
where hasUnreachableExceptBlock(earlierExcept, generalExceptClass, laterExcept, specificExceptClass)
// 选择 laterExcept 作为结果，并生成一条警告信息
select laterExcept,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificExceptClass, specificExceptClass.getName(), earlierExcept, "except block", 
  generalExceptClass, generalExceptClass.getName()