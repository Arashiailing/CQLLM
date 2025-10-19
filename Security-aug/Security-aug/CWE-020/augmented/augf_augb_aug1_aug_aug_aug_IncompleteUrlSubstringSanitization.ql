/**
 * @name 不完整的URL子串消毒
 * @description 对未解析URL的子串进行安全检查存在绕过风险，
 *              因为这些检查未考虑完整的URL结构
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-url-substring-sanitization
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.regex

// 定义用于URL验证的常见顶级域名正则表达式模式
private string getTopLevelDomainPattern() { result = "com|org|edu|gov|uk|net|io" }

// 判断字符串字面量是否包含URL特征模式
predicate hasUrlCharacteristics(StringLiteral urlLiteral) {
  exists(string literalContent | literalContent = urlLiteral.getText() |
    literalContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getTopLevelDomainPattern() + ")(:[0-9]+)?/?")
    or
    literalContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// 检测直接字符串比较操作
predicate isDirectStringComparison(Expr sanitizationOp, StringLiteral urlLiteral) {
  exists(Compare comparisonOp | 
    comparisonOp.compares(urlLiteral, any(In i), _) and
    sanitizationOp = comparisonOp
  )
}

// 检测不安全的startswith使用
predicate isUnsafeStartsWithUsage(Expr sanitizationOp, StringLiteral urlLiteral) {
  exists(Call methodCall | 
    methodCall.getFunc().(Attribute).getName() = "startswith" and
    methodCall.getArg(0) = urlLiteral and
    not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
    sanitizationOp = methodCall
  )
}

// 检测不安全的endswith使用
predicate isUnsafeEndsWithUsage(Expr sanitizationOp, StringLiteral urlLiteral) {
  exists(Call methodCall | 
    methodCall.getFunc().(Attribute).getName() = "endswith" and
    methodCall.getArg(0) = urlLiteral and
    not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
    sanitizationOp = methodCall
  )
}

// 识别执行不完整URL子串消毒的表达式
predicate exhibitsIncompleteSanitization(Expr sanitizationOp, StringLiteral urlLiteral) {
  hasUrlCharacteristics(urlLiteral) and
  (
    isDirectStringComparison(sanitizationOp, urlLiteral) or
    isUnsafeStartsWithUsage(sanitizationOp, urlLiteral) or
    isUnsafeEndsWithUsage(sanitizationOp, urlLiteral)
  )
}

// 查找所有存在不完整URL子串消毒模式的表达式
from Expr sanitizationOp, StringLiteral urlLiteral
where exhibitsIncompleteSanitization(sanitizationOp, urlLiteral)
select sanitizationOp, "字符串 $@ 可能位于被消毒URL的任意位置。", urlLiteral,
  urlLiteral.getText()