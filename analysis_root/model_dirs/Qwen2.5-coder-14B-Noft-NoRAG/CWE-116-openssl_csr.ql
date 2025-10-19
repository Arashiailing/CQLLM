import python

/**
 * This query detects the CWE-116: Path Injection vulnerability
 * by looking for the use of regular expressions to match HTML tags.
 */

from Regex regex, Call call
where call.getCallee().getName() = "re.compile"
  and call.getArgument(0) = regex
  and regex.matches(".*<.*>.*")
select call, "This call to re.compile may be vulnerable to CWE-116: Path Injection due to the use of regular expressions to match HTML tags."