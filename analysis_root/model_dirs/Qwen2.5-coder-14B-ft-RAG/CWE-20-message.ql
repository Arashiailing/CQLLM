/**
 * @name Improper input validation (CWE-20)
 * @description The product receives input or data, but it does not validate or
 *              incorrectly validates that the input has the properties that are
 *              required to process the data safely and correctly.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-hostname-regexp
 * @tags correctness
 *       security
 *       external/cwe/cwe-020
 */

import semmle.python.security.regexp.HostnameRegex

predicate incomplete_hostname_re(StringLiteral re) {
  exists(int n |
    n = 0 and
    (
      n = re.getText().count(".") or
      n = re.getText().count(".\\")
    )
  )
}

from StringLiteral re
where
  incomplete_hostname_re(re)
  and
  exists(Term term |
    term.regexpMatch(re)
    and
    not exists(term.(ClassValue))
  )
select re, "The string $@ may be at an arbitrary position in the sanitized URL.", re.getText()