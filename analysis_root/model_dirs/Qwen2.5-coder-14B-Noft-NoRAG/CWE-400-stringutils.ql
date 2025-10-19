import python

/**
 * This query detects CWE-400: Uncontrolled Resource Consumption
 * Specifically, it looks for potential Polynomial Regular Expression Denial of Service (ReDoS) vulnerabilities.
 */

from RegexPattern pattern, String s
where pattern.getPattern() = s and s.matches(".*\\*+.*") or s.matches(".*\\++.*") or s.matches(".*\\{.*\\}.*")
select pattern, "This regular expression pattern may lead to a Polynomial ReDoS vulnerability."