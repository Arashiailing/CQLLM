/**
 * @name CWE-330: Use of Insufficiently Random Values
 * @description The product uses insufficiently random numbers or values in a security context that depends on unpredictable numbers.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/packet
 * @tags security
 *       external/cwe/cwe-330
 */

import python
import semmle.python.filters.Tests

predicate is_ignored_source(File f) {
  f.getRelativeFilename() = "tests/sensitive_data_hashing.py"
}

predicate has_sensitive_data(Expr e) {
  exists(SensitiveData::HashAlgorithm hash |
    (
      hash.getFunction().getScope().getScope*().getScope*() instanceof Module and
      not hash.getModule().getScope*().getScope*().getScope*() instanceof TestScope and
      not is_ignored_source(hash.getFile())
    )
    or
    exists(string name | name in [
                                  "blake2b",
                                  "blake2s",
                                  "md5",
                                  "sha1",
                                  "sha224",
                                  "sha256",
                                  "sha384",
                                  "sha512"
                                ] |
      e.(Name).getId() = name
    )
  |
    e = hash.getConfiguration()
  )
}

predicate has_insufficient_entropy(ControlFlowNode cfgNode) {
  exists(int n |
    exists(InsecureHashFunction::functionCall(_, _)) and
    exists(InsecureHashFunction::functionCall(f, _).getAnArg(i), ValueWithLocation val |
      val.asCfgNode() = cfgNode and
      i = 0 and
      f.getScope().getScope*().getScope*() instanceof Module and
      not f.getModule().getScope*().getScope*().getScope*() instanceof TestScope and
      not is_ignored_source(val.getLocation().getFile()) and
      (n = 256 or n = 512) and
      (
        exists(Call call |
          call = f.getACall() and
          val.asCfgNode() = call.getArgByName("digest_size")
        |
          val.getAValueReachingSink().asExpr() =
            ImmutableLiteral::integer(n).asExpr()
        )
        or
        not exists(call)
      )
    )
  )
  or
  exists(
    int n,
    ValueWithLocation val,
    Call f |
    f.getScope().getScope*().getScope*() instanceof Module and
    not f.getModule().getScope*().getScope*().getScope*() instanceof TestScope and
    not is_ignored_source(val.getLocation().getFile()) and
    (n = 16 or n = 20) and
    cfgNode = f.getArgByName("length") and
    f.getFunc().(Attribute).getName() = "randint" and
    val.asCfgNode() = f.getArgByName("a") and
    val.getAValueReachingSink().asExpr() =
      ImmutableLiteral::integer(n).asExpr()
  )
}

from ControlFlowNode cfgNode, Expr e
where
  has_sensitive_data(e) and
  cfgNode.asExpr() = e and
  has_insufficient_entropy(cfgNode)
select e, "Insufficient entropy in sensitive data hashing algorithm."