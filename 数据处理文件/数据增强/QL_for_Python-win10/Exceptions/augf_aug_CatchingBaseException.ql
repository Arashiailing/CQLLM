/**
 * @name Exception block catches 'BaseException'
 * @description Capturing 'BaseException' can lead to improper handling of system exits and keyboard interrupts.
 * @kind problem
 * @tags reliability
 *       readability
 *       convention
 *       external/cwe/cwe-396
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/catch-base-exception
 */

import python
import semmle.python.ApiGraphs

// 检查异常处理块是否不会重新抛出捕获的异常
// 通过分析控制流，确定异常处理块的基本块是否能够到达程序退出点
predicate doesNotReraise(ExceptStmt exceptionHandler) { 
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

// 确定异常处理块是否捕获了BaseException或其子类
// 包括两种情况：显式捕获BaseException，或者使用裸except子句（未指定异常类型）
predicate catchesBaseException(ExceptStmt exceptionHandler) {
  // 检查异常类型是否为BaseException
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // 检查是否为裸except子句（未指定异常类型）
  not exists(exceptionHandler.getType())
}

// 主查询：识别潜在问题模式
// 查找同时满足以下两个条件的异常处理块：
// 1. 捕获了BaseException（包括裸except子句）
// 2. 不会重新抛出异常
from ExceptStmt exceptionHandler
where
  catchesBaseException(exceptionHandler) and 
  doesNotReraise(exceptionHandler)
select exceptionHandler, "Except block directly handles BaseException."