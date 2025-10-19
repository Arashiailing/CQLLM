/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

import python
import semmle.python.security.regexp.HostnameRegex

predicate problems(string msg, string re, string prefix, string suffix) {
  exists(HostnameRegex::incompleteHostnameRegExp(msg, re, prefix, suffix))
}

from string message, string regex, string prefix, string suffix
where problems(message, regex, prefix, suffix)
select message,
  "The hostname pattern '" + regex + "' will match too many host names (" +
    "prefix: '" + prefix + "', suffix: '" + suffix + "')", prefix, suffix