/**
 * @name CWE CATEGORY: 7PK - Security Features
 * @description nan
 * @kind problem
 * @id py/compile_helpers
 */

private import semmle.python.regularexpressions.RegexHelper as RegexHelper

query predicate problems = RegexHelper::unterminatedCharacterClass/4;