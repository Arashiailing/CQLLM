import python

/**
 * @name CWE-787: Out-of-bounds Write
 * @description The product writes data past the end, or before the beginning, of the intended buffer.
 * @id py/gperf_unfold_key_conv
 */
from Call call, IntegerLiteral index, List list
where call.getTarget() = List::get
  and call.getArg(0) = index
  and index.getValue() >= list.getLength()
select call, "Potential out-of-bounds write due to invalid index."