/**
 * @name Import of deprecated module
 * @description Import of a deprecated module
 * @kind problem
 * @tags maintainability
 *       external/cwe/cwe-477
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/import-deprecated-module
 */

// 导入Python库，用于处理Python代码的查询
import python

/**
 * 判断模块 `name` 是否在指定的 Python 版本 `major` . `minor` 中被弃用，
 * 并且应该使用模块 `instead` 代替（或 `instead = "no replacement"`）
 *
 * @param name 模块名称
 * @param instead 替代模块的名称，如果没有替代则为 "no replacement"
 * @param major 主版本号
 * @param minor 次版本号
 * @return 如果模块在指定版本中被弃用且有替代模块，则返回 true
 */
predicate deprecated_module(string name, string instead, int major, int minor) {
  // 检查模块是否在特定版本中被弃用以及是否有替代模块
  name = "posixfile" and instead = "fcntl" and major = 1 and minor = 5
  or
  name = "gopherlib" and instead = "no replacement" and major = 2 and minor = 5
  or
  name = "rgbimgmodule" and instead = "no replacement" and major = 2 and minor = 5
  or
  name = "pre" and instead = "re" and major = 1 and minor = 5
  or
  name = "whrandom" and instead = "random" and major = 2 and minor = 1
  or
  name = "rfc822" and instead = "email" and major = 2 and minor = 3
  or
  name = "mimetools" and instead = "email" and major = 2 and minor = 3
  or
  name = "MimeWriter" and instead = "email" and major = 2 and minor = 3
  or
  name = "mimify" and instead = "email" and major = 2 and minor = 3
  or
  name = "rotor" and instead = "no replacement" and major = 2 and minor = 4
  or
  name = "statcache" and instead = "no replacement" and major = 2 and minor = 2
  or
  name = "mpz" and instead = "a third party" and major = 2 and minor = 2
  or
  name = "xreadlines" and instead = "no replacement" and major = 2 and minor = 3
  or
  name = "multifile" and instead = "email" and major = 2 and minor = 5
  or
  name = "sets" and instead = "builtins" and major = 2 and minor = 6
  or
  name = "buildtools" and instead = "no replacement" and major = 2 and minor = 3
  or
  name = "cfmfile" and instead = "no replacement" and major = 2 and minor = 4
  or
  name = "macfs" and instead = "no replacement" and major = 2 and minor = 3
  or
  name = "md5" and instead = "hashlib" and major = 2 and minor = 5
  or
  name = "sha" and instead = "hashlib" and major = 2 and minor = 5
}

/**
 * 获取模块的弃用信息消息
 *
 * @param mod 模块名称
 * @return 包含模块弃用版本的字符串消息
 */
string deprecation_message(string mod) {
  // 如果模块在某一版本中被弃用，生成相应的消息
  exists(int major, int minor | deprecated_module(mod, _, major, minor) |
    result =
      "The " + mod + " module was deprecated in version " + major.toString() + "." +
        minor.toString() + "."
  )
}

/**
 * 获取模块的替代建议消息
 *
 * @param mod 模块名称
 * @return 包含替代模块建议的字符串消息，如果没有替代则为空字符串
 */
string replacement_message(string mod) {
  // 如果存在替代模块，生成相应的替代建议消息
  exists(string instead | deprecated_module(mod, instead, _, _) |
    result = " Use " + instead + " module instead." and not instead = "no replacement"
    or
    result = "" and instead = "no replacement"
  )
}

// 从导入表达式中选择被弃用的模块，并生成相应的警告消息
from ImportExpr imp, string name, string instead
where
  // 获取导入的模块名称
  name = imp.getName() and
  // 检查模块是否被弃用
  deprecated_module(name, instead, _, _) and
  // 确保导入语句没有被 try-except 块捕获 ImportError
  not exists(Try try, ExceptStmt except | except = try.getAHandler() |
    except.getType().pointsTo(ClassValue::importError()) and
    except.containsInScope(imp)
  )
select imp, deprecation_message(name) + replacement_message(name)
