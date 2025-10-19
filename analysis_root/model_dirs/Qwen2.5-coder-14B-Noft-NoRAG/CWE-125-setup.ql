import python

/**
 * CWE-125: Out-of-bounds Read
 * Detects instances where data is read out of the bounds of a buffer.
 */
from ArrayAccess arrAccess
where arrAccess.getArray() instanceof List and
      arrAccess.getIndex() instanceof BinaryExpr and
      arrAccess.getIndex().getOperator() = "+"
select arrAccess, "Potential out-of-bounds read detected."