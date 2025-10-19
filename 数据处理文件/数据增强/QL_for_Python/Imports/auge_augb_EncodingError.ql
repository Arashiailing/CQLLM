/**
 * @name Encoding Error Detection
 * @description Identifies encoding anomalies causing runtime failures and impeding static analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

from EncodingError encodingFault select encodingFault, encodingFault.getMessage()