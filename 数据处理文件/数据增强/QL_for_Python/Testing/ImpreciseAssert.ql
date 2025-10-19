/**
 * @name Imprecise assert
 * @description Using 'assertTrue' or 'assertFalse' rather than a more specific assertion can give uninformative failure messages.
 * @kind problem
 * @tags maintainability
 *       testability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/imprecise-assert
 */

import python

/* Helper predicate for CallToAssertOnComparison class */
predicate callToAssertOnComparison(Call call, string assertName, Cmpop op) {
  // 检查调用的函数名称是否为指定的断言方法名，并且是 'assertTrue' 或 'assertFalse'
  call.getFunc().(Attribute).getName() = assertName and
  (assertName = "assertTrue" or assertName = "assertFalse") and
  exists(Compare cmp |
    // 获取调用的第一个参数，并确保它是一个比较操作
    cmp = call.getArg(0) and
    /* Exclude complex comparisons like: a < b < c */
    // 排除复杂的比较操作，如：a < b < c
    not exists(cmp.getOp(1)) and
    op = cmp.getOp(0)
  )
}

class CallToAssertOnComparison extends Call {
  // 构造函数，初始化时调用辅助谓词进行匹配
  CallToAssertOnComparison() { callToAssertOnComparison(this, _, _) }

  // 获取比较操作符
  Cmpop getOperator() { callToAssertOnComparison(this, _, result) }

  // 获取断言方法的名称
  string getMethodName() { callToAssertOnComparison(this, result, _) }

  // 获取更具体的断言方法名称
  string getBetterName() {
    exists(Cmpop op |
      callToAssertOnComparison(this, "assertTrue", op) and
      (
        op instanceof Eq and result = "assertEqual"
        or
        op instanceof NotEq and result = "assertNotEqual"
        or
        op instanceof Lt and result = "assertLess"
        or
        op instanceof LtE and result = "assertLessEqual"
        or
        op instanceof Gt and result = "assertGreater"
        or
        op instanceof GtE and result = "assertGreaterEqual"
        or
        op instanceof In and result = "assertIn"
        or
        op instanceof NotIn and result = "assertNotIn"
        or
        op instanceof Is and result = "assertIs"
        or
        op instanceof IsNot and result = "assertIsNot"
      )
      or
      callToAssertOnComparison(this, "assertFalse", op) and
      (
        op instanceof NotEq and result = "assertEqual"
        or
        op instanceof Eq and result = "assertNotEqual"
        or
        op instanceof GtE and result = "assertLess"
        or
        op instanceof Gt and result = "assertLessEqual"
        or
        op instanceof LtE and result = "assertGreater"
        or
        op instanceof Lt and result = "assertGreaterEqual"
        or
        op instanceof NotIn and result = "assertIn"
        or
        op instanceof In and result = "assertNotIn"
        or
        op instanceof IsNot and result = "assertIs"
        or
        op instanceof Is and result = "assertIsNot"
      )
    )
  }
}

from CallToAssertOnComparison call
where
  /* Exclude cases where an explicit message is provided*/
  // 排除提供了显式消息的情况
  not exists(call.getArg(1))
select call,
  // 选择调用和建议信息，指出使用更具体的断言方法可以提供更有信息量的消息
  call.getMethodName() + "(a " + call.getOperator().getSymbol() + " b) " +
    "cannot provide an informative message. Using " + call.getBetterName() +
    "(a, b) instead will give more informative messages."
