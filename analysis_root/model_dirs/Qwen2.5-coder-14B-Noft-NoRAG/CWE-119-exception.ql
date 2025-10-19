import python

/**
 * This query detects CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * in Python code.
 */

from ArrayAccess arrAccess
where arrAccess.getIndex().(IntegerLiteral) > arrAccess.getArray().getElementCount()
select arrAccess, "Potential out-of-bounds array access detected."