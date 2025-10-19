import python

/**
 * This query detects CWE-400: Uncontrolled Resource Consumption
 * Specifically, it looks for potential Polynomial Regular Expression Denial of Service (ReDoS) vulnerabilities.
 */

from Regex regex, StringPattern pattern
where regex.getPattern() = pattern and pattern.isPolynomial()
select regex, "This regular expression pattern may lead to a Polynomial ReDoS vulnerability."