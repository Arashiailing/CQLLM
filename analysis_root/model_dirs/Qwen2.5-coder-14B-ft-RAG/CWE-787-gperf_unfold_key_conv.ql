/**
 * @name CWE-787: Out-of-bounds Write
 * @description The product writes data past the end, or before the beginning, of the intended buffer.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/gperf_unfold_key_conv
 * @tags correctness
 *       security
 *       external/cwe/cwe-787
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.StringTerminals

from StringTerminal src, StringTerminal tgt
where
  exists(TaintTree::PropagationStep step |
    step = TaintTree::propagation(src, tgt)
  )
select tgt, "$@ propagates through string formatting operations", src,
  src.toString()