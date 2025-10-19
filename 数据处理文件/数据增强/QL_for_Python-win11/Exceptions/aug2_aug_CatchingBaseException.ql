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

// 检查异常处理块是否没有重新抛出异常
// 通过分析控制流，判断异常处理块的基本块是否能到达程序退出点
predicate doesNotReraise(ExceptStmt exceptionHandler) { 
  exceptionHandler.getAFlowNode().getBasicBlock().reachesExit() 
}

// 判断异常处理块是否捕获了BaseException
// 包括直接捕获BaseException或未指定异常类型（相当于捕获所有异常）
predicate catchesBaseException(ExceptStmt exceptionHandler) {
  // 检查异常类型是否为BaseException
  exceptionHandler.getType() = API::builtin("BaseException").getAValueReachableFromSource().asExpr()
  or
  // 或者未指定异常类型（裸except子句）
  not exists(exceptionHandler.getType())
}

// 主查询：识别不恰当的BaseException处理模式
// 查找同时满足以下条件的异常处理块：
// 1. 捕获了BaseException（或所有异常）
// 2. 没有重新抛出异常
from ExceptStmt exceptionHandler
where
  catchesBaseException(exceptionHandler) and
  doesNotReraise(exceptionHandler)
select exceptionHandler, "Except block directly handles BaseException."