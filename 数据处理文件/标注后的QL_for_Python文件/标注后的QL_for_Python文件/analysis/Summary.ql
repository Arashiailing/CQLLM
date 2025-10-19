/**
 * Summarize a snapshot
 */

import python

// 从键值对中选择数据，其中键为字符串类型，值为字符串类型
from string key, string value
where
  // 如果键是 "Extractor version" 并且 py_flags_versioned 函数返回 true，则将对应的值赋给 value
  key = "Extractor version" and py_flags_versioned("extractor.version", value, _)
  or
  // 如果键是 "Snapshot build time" 并且存在一个日期 d 满足 snapshotDate(d) 条件，则将日期转换为字符串并赋给 value
  key = "Snapshot build time" and
  exists(date d | snapshotDate(d) and value = d.toString())
  or
  // 如果键是 "Interpreter version" 并且存在 major 和 minor 版本号，则将它们组合成 "major.minor" 格式的字符串并赋给 value
  key = "Interpreter version" and
  exists(string major, string minor |
    py_flags_versioned("extractor_python_version.major", major, _) and
    py_flags_versioned("extractor_python_version.minor", minor, _) and
    value = major + "." + minor
  )
  or
  // 如果键是 "Build platform" 并且存在一个原始平台字符串 raw，则根据不同的平台名称将其转换为更友好的值并赋给 value
  key = "Build platform" and
  exists(string raw | py_flags_versioned("sys.platform", raw, _) |
    if raw = "win32"
    then value = "Windows"
    else
      if raw = "linux2"
      then value = "Linux"
      else
        if raw = "darwin"
        then value = "OSX"
        else value = raw
  )
  or
  // 如果键是 "Source location" 并且 sourceLocationPrefix 函数返回 true，则将前缀路径赋给 value
  key = "Source location" and sourceLocationPrefix(value)
  or
  // 如果键是 "Lines of code (source)"，则计算所有模块的源代码行数总和并转换为字符串赋给 value
  key = "Lines of code (source)" and
  value =
    sum(ModuleMetrics m | exists(m.getFile().getRelativePath()) | m.getNumberOfLinesOfCode())
        .toString()
  or
  // 如果键是 "Lines of code (total)"，则计算所有模块的总行数并转换为字符串赋给 value
  key = "Lines of code (total)" and
  value = sum(ModuleMetrics m | any() | m.getNumberOfLinesOfCode()).toString()
select key, value
