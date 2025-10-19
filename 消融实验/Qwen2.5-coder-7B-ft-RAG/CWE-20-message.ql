/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision high
 * @id py/message
 * @tags security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.security.dataflow.IncompleteHostnameRegExpQuery
private import semmle.python.security.regexp.HostnameRegex as HostnameRegex

predicate problems = HostnameRegex::incompleteHostnameRegExp/4;