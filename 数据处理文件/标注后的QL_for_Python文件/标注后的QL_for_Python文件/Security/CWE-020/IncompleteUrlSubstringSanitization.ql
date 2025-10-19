/**
 * @name Incomplete URL substring sanitization
 * @description Security checks on the substrings of an unparsed URL are often vulnerable to bypassing.
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

// 定义一个私有字符串函数，返回常见的顶级域名正则表达式
private string commonTopLevelDomainRegex() { result = "com|org|edu|gov|uk|net|io" }

// 定义一个谓词函数，判断给定的字符串字面量是否看起来像一个URL
predicate looksLikeUrl(StringLiteral s) {
  exists(string text | text = s.getText() |
    text.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTopLevelDomainRegex() +
        ")(:[0-9]+)?/?")
    or
    // 目标是任意TLD域的HTTP URL
    text.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// 定义一个谓词函数，判断是否存在不完整的URL子串清理操作
predicate incomplete_sanitization(Expr sanitizer, StringLiteral url) {
  looksLikeUrl(url) and
  (
    sanitizer.(Compare).compares(url, any(In i), _)
    or
    unsafe_call_to_startswith(sanitizer, url)
    or
    unsafe_call_to_endswith(sanitizer, url)
  )
}

// 定义一个谓词函数，判断是否存在不安全的startswith调用
predicate unsafe_call_to_startswith(Call sanitizer, StringLiteral url) {
  sanitizer.getFunc().(Attribute).getName() = "startswith" and
  sanitizer.getArg(0) = url and
  not url.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// 定义一个谓词函数，判断是否存在不安全的endswith调用
predicate unsafe_call_to_endswith(Call sanitizer, StringLiteral url) {
  sanitizer.getFunc().(Attribute).getName() = "endswith" and
  sanitizer.getArg(0) = url and
  not url.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// 查询语句：查找所有存在不完整URL子串清理操作的表达式和对应的URL字符串
from Expr sanitizer, StringLiteral url
where incomplete_sanitization(sanitizer, url)
select sanitizer, "The string $@ may be at an arbitrary position in the sanitized URL.", url,
  url.getText()
