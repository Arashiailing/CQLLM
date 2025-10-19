/**
 * @name CWE-787: Out-of-bounds Write
 * @description The product writes data past the end, or before the beginning, of the intended buffer.
 * @kind problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.1
 * @id py/gperf_unfold_key_conv
 * @tags correctness
 *       security
 *       external/cwe/cwe-120
 */

import python
import gperftools.UnfoldKeyConverter

from GPerfUnfoldKeyConverter unfoldkeyconv, string description
where
  unfoldkeyconv.hasBug() and
  description = unfoldkeyconv.getErrorMessage()
select unfoldkeyconv, "The key converter does not check that its output fits within the allocated space, which leads to a buffer overflow."