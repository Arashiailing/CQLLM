import python

/**
 * This query detects CWE-681: Incorrect Conversion between Numeric Types.
 * It looks for explicit conversions between numeric types that may lead to loss of precision or unexpected behavior.
 */

from CastExpr cast
where cast.getDestType() instanceof NumericType and
      cast.getSrcType() instanceof NumericType and
      cast.getSrcType()!= cast.getDestType()
select cast, "This cast may lead to incorrect conversion between numeric types, potentially causing loss of precision or unexpected behavior."