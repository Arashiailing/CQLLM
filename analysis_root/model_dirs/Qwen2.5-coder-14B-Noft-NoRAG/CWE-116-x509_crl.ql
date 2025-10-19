import python

/**
 * This query detects potential instances of CWE-116: Reflected XSS vulnerabilities
 * in Python code where regular expressions are used to match HTML tags.
 */

from Call call, Regex regex, StringPattern pattern
where call.getCallee().getName() = "re.match" or call.getCallee().getName() = "re.search"
  and call.getArgument(0) = regex
  and regex.getPattern() = pattern
  and pattern.getText() contains "<"
  and pattern.getText() contains ">"
select call, "This call to re.match or re.search with a regex pattern containing HTML tags may lead to reflected XSS vulnerabilities."