import python

from File file, BinaryOperation binOp, StringLiteral strLit
where binOp.getOperator() = "+"
  and binOp.getLeftOperand() instanceof StringLiteral
  and binOp.getRightOperand() instanceof StringLiteral
  and strLit = binOp.getLeftOperand() or strLit = binOp.getRightOperand()
select file, binOp, "Potential CWE-125: Out-of-bounds Read detected."