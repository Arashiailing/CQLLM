import python

/**
 * Query to detect CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * This query looks for the use of weak hashing algorithms for sensitive data.
 */

class WeakHashFunction extends Function {
  WeakHashFunction() {
    this.getName() = "md5" or
    this.getName() = "sha1" or
    this.getName() = "crc32" or
    this.getName() = "adler32"
  }
}

class SensitiveDataHandling extends Call {
  SensitiveDataHandling() {
    exists(WeakHashFunction wf |
      this.getCallee() = wf and
      this.getArgument(0).getValue() instanceof StringLiteral and
      this.getArgument(0).getValue().getValue().matches("%(password|secret|key|token)%")
    )
  }
}

from SensitiveDataHandling sdh
select sdh, "This code uses a weak hashing algorithm to handle sensitive data."