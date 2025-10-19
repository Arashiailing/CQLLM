/**
 * @name TarSlipQuery
 * @description Extracting files from a malicious tarfile without validating the target file path
 *              can allow an attacker to overwrite files outside the intended directory.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/tarslip
 */

import python
import experimental.semmle.python.security.ZipSlip

from TarFileExtractCall extractCall, PathNode source, PathNode sink
where TarSlipFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This tarfile extraction may allow arbitrary file writes."