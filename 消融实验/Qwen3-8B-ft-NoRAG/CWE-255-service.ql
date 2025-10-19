import python
import security

from StringLiteral s, File f
where s.getContainer() = f and f.getFilePath() matches ".*\.json$" and (s.getValue() matches "password" or s.getValue() matches "secret")
select f, "Potential credential storage in JSON configuration file"

from StringLiteral s, Call c
where c.getDeclaringFunction().getName() = "requests.get" and c.getArgument(0).getValue() = s and s.getValue() matches ".*password.*"
select c, "Hardcoded password in requests.get call"

from Secret s
select s, "Detected sensitive information"