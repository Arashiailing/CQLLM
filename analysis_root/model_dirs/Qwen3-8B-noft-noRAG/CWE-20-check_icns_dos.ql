import python
import regex

from Regex r
where r.hasReDosVulnerability()
select r, "This regular expression may be vulnerable to a Polynomial ReDoS attack."