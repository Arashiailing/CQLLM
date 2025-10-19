import python

from FunctionCall fc, RegexLiteral rl
where fc.getCallee().getName() = "re.search" and
      fc.getArgument(0) = rl and
      rl.getValue().matches(".*<.*>.*")
select fc, "This function call uses a regular expression to match HTML tags, which can lead to reflected XSS vulnerabilities."