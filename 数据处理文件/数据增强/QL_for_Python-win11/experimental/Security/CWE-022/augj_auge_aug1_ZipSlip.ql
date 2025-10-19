/**
 * @name Arbitrary file access during archive extraction ("Zip Slip")
 * @description Identifies unsafe archive extraction where paths containing '..' 
 *              can bypass directory restrictions, enabling unauthorized file access.
 * @kind path-problem
 * @id py/zipslip
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       experimental
 *       external/cwe/cwe-022
 */

import python
import experimental.semmle.python.security.ZipSlip
import ZipSlipFlow::PathGraph

// Find vulnerable data flows from archive entries to file operations
from ZipSlipFlow::PathNode taintedEntry, ZipSlipFlow::PathNode sinkOp
where ZipSlipFlow::flowPath(taintedEntry, sinkOp)

// Generate vulnerability report with flow path context
select taintedEntry.getNode(), taintedEntry, sinkOp,
  "This unsanitized archive entry (potentially containing '..') reaches a $@.", sinkOp.getNode(),
  "file system operation"