/**
 * 生成数据库快照摘要信息
 */

import python

// 从字符串键值对中提取快照相关信息
from string metricName, string metricValue
where
  // 提取器版本信息：获取版本号字符串
  metricName = "Extractor version" and py_flags_versioned("extractor.version", metricValue, _)
  or
  // 快照构建时间：获取构建日期并转换为字符串
  metricName = "Snapshot build time" and
  exists(date buildDate | snapshotDate(buildDate) and metricValue = buildDate.toString())
  or
  // Python解释器版本：获取主版本和次版本号并组合
  metricName = "Interpreter version" and
  exists(string majorVer, string minorVer |
    py_flags_versioned("extractor_python_version.major", majorVer, _) and
    py_flags_versioned("extractor_python_version.minor", minorVer, _) and
    metricValue = majorVer + "." + minorVer
  )
  or
  // 构建平台信息：将原始平台标识转换为用户友好的名称
  metricName = "Build platform" and
  exists(string platformRaw | py_flags_versioned("sys.platform", platformRaw, _) |
    if platformRaw = "win32"
    then metricValue = "Windows"
    else
      if platformRaw = "linux2"
      then metricValue = "Linux"
      else
        if platformRaw = "darwin"
        then metricValue = "OSX"
        else metricValue = platformRaw
  )
  or
  // 源代码位置：获取源代码根目录路径
  metricName = "Source location" and sourceLocationPrefix(metricValue)
  or
  // 源代码行数统计：计算所有模块的源代码行数总和
  metricName = "Lines of code (source)" and
  metricValue =
    sum(ModuleMetrics moduleStats | exists(moduleStats.getFile().getRelativePath()) | moduleStats.getNumberOfLinesOfCode())
        .toString()
  or
  // 总行数统计：计算所有模块的总行数
  metricName = "Lines of code (total)" and
  metricValue = sum(ModuleMetrics moduleStats | any() | moduleStats.getNumberOfLinesOfCode()).toString()
select metricName, metricValue