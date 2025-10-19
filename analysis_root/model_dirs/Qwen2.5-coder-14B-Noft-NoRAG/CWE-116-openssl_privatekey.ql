import python

/**
 * This query detects instances where HTML tags are matched using regular expressions,
 * which can lead to Log Injection vulnerabilities (CWE-116).
 */

from Call call, RegexLiteral regex
where call.getCallee().getName() = "re.match" and
      regex.getValue().matches(".*<.*>.*")
select call, "Potentially vulnerable HTML tag matching using regular expressions."