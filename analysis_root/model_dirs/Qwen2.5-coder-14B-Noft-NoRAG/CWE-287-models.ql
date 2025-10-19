import python

/**
 * CWE-287: Improper Authentication
 * 
 * This query detects cases where authentication is not properly verified.
 */

from FunctionCall authCall, Function authFunc
where authCall.getTarget() = authFunc and
      authFunc.getName() = "authenticate" and
      not exists(Expr proofExpr |
          proofExpr instanceof BinaryExpr and
          proofExpr.getOperator() = "==" and
          proofExpr.getLeftOperand() = authCall.getArgument(0) and
          proofExpr.getRightOperand() = authCall.getArgument(1)
      )
select authCall, "Improper authentication detected. The authentication function does not verify the identity properly."