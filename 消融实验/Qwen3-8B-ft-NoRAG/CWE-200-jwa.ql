import python
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.security.Secrets

from File file, String string
where
  (file.hasString(string) and
   string.matches("password|secret|token|key|cred|api|auth|private|confidential|sensitive") and
   string.matches("[a-zA-Z0-9]{32,}")) or
  (string.matches("logging\\.info|print|sys\\.stdout") and
   string.matches(".*[a-zA-Z0-9]{32,}.*"))
select file, "Potential exposure of sensitive information in file: " + file.path