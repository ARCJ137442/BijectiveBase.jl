<!-- ⚠️该文件由 `BijectiveNumeration.ipynb` 自动生成于 2024-01-31T20:38:19.986，无需手动修改 -->
# BijectiveNumeration.jl

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Static Badge](https://img.shields.io/badge/julia-package?logo=julia&label=1.4%2B)](https://julialang.org/)

[![CI status](https://github.com/ARCJ137442/BijectiveNumeration.jl/workflows/CI/badge.svg)](https://github.com/ARCJ137442/BijectiveNumeration.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/ARCJ137442/BijectiveNumeration.jl/graph/badge.svg?token=PCQHEU15L0)](https://codecov.io/gh/ARCJ137442/BijectiveNumeration.jl)

该项目使用[语义化版本 2.0.0](https://semver.org/)进行版本号管理。

## 概述

🎯核心功能：为「双射进位制」提供**解析、转换**支持

- 有「数组」「字符串」两种形式可选
  - 数组形式更为通用
  - 字符串形式更为常用

📌概念「双射进位制」  

- 与常规「N进制数值」的区别：**没有表特殊地位的「0」位值**
  - 这意味着「A」与「AA」在任何N下语义都不相同
  - 🔗细节可参看[下表](#对照表)

## 对照表

部分二进制数的对应关系表如下：

| 原 | BIN | Bijective BIN | 权值显示 |
| ---: | ---: | ---: | ---: |
| 0 | 0 |  |  |
| 1 | 1 | 0 | 1 |
| 2 | 10 | 1 | 2 |
| 3 | 11 | 00 | 21 |
| 4 | 100 | 01 | 22 |
| 5 | 101 | 10 | 41 |
| 6 | 110 | 11 | 42 |
| 7 | 111 | 000 | 421 |
| 8 | 1000 | 001 | 422 |
| 9 | 1001 | 010 | 441 |
| 10 | 1010 | 011 | 442 |
| 11 | 1011 | 100 | 821 |
| 12 | 1100 | 101 | 822 |
| 13 | 1101 | 110 | 841 |
| 14 | 1110 | 111 | 842 |
| 15 | 1111 | 0000 | 8421 |
| $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ |

^其中**空白单元格**表示「空字符串」

## 使用

### 代码概览

该Julia包导出了三个函数，分别为

- 📌`length_bijective`：**计算数值在「双射进位制」下的位数**
  - ⚙️方法：指定进制
    - 🏷️签名：`length_bijective(x::Integer, N::Integer) -> Integer`
    - ✨功能：计算数值`x`在「双射`N`进位制」下的位数
  - ⚙️方法：指定进制字符集
    - 🏷️签名：`length_bijective(x::Integer, chars::AbstractString) -> Integer`
    - ✨功能：计算数值`x`在以`chars`为`N`进制字符集的「双射`N`进位制」下的位数
- 📌`num_to_bijective`：**将数值转换为双射进位制的符号串**
  - ⚙️方法：基数+映射
    - 🏷️签名：`num_to_bijective(x::Integer, N::Integer, f::Function=identity, T::Type=Any) -> Vector{T}`
    - ✨功能：将数值`x`通过「符号→位值」的映射`f`转换为双射`N`进位制的符号串
    - 🔧参数：映射`f`
      - 默认：恒等函数`identity`，即使用**1~N**作为符号值
  - ⚙️方法：进制字符集
    - 🏷️签名：`num_to_bijective(x::Integer, chars::AbstractString) -> String`
    - ✨功能：将数值`x`通过指定的「进制字符集」`chars`转换为双射进位制的字符串
- 📌`bijective_to_num`：**将双射进位制符号串解析为数值**
  - ⚙️方法：基数+映射
    - 🏷️签名：`bijective_to_num(s::Vector, N::Integer, f⁻¹::Function=identity, I::Type{<:Integer}=Int) -> I`
    - ✨功能：将双射`N`进位制的符号串`s`通过「符号→位值」的逆映射`f⁻¹`转换成类型为I的数值
    - 🔧参数：映射`f`
      - 默认：恒等函数`identity`，即使用**1~N**作为符号值
    - 🔧参数`I`：输出的整数类型
      - 填写`BigInt`以兼容大整数`BigInt`
      - 默认：`Int`
  - ⚙️方法：进制字符集
    - 🏷️签名：`bijective_to_num(s::AbstractString, chars::AbstractString, I::Type{<:Integer}=Int) -> I`
    - ✨功能：将双射进位制的符号串`s`通过指定的「进制字符集」`chars`转换成类型为I的数值
    - 🔧参数`I`：输出的整数类型
      - 填写`BigInt`以兼容大整数`BigInt`
      - 默认：`Int`

对函数参数Curly化的支持：

- 📌`num_to_bijective`
  - ⚙️方法：基数+映射
    - 🏷️签名：`num_to_bijective(N::Integer, f::Function=identity, T::Type=Any) -> Function`
    - ✨功能：生成一个纯粹的「双射进制转换函数」 
      - 即 `num_to_bijective(N, f, T)(x)` 等价于 `num_to_bijective(x, N, f, T)`
      - 可用于管道和广播操作：`x |> num_to_bijective(N, f, T)`、`num_to_bijective(N, f, T).([x, y, z])`
  - ⚙️方法：进制字符集
    - 🏷️签名：`num_to_bijective(chars::AbstractString, args...) -> Function`
    - ✨功能：生成一个纯粹的「双射进制转换函数」 
      - 即 `num_to_bijective(chars, args...)(x)` 等价于 `num_to_bijective(x, chars, args...)`
      - 可用于管道和广播操作：`x |> num_to_bijective(chars, args...)`、`num_to_bijective(chars, args...).([x, y, z])`
- 📌`bijective_to_num`
  - ⚙️方法：进制+映射
    - 🏷️签名：`bijective_to_num(N::Integer, f⁻¹::Function=identity, I::Type{<:Integer}=Int) -> Function`
    - ✨功能：生成一个纯粹的「双射进制转换函数」 
      - 即 `bijective_to_num(N, f⁻¹, I)(s)` 等价于 `bijective_to_num(s, N, f⁻¹, I)`
      - 可用于管道和广播操作：`s |> bijective_to_num(N, f⁻¹, I)`、`bijective_to_num(N, f⁻¹, I).([p, q, r])`
  - ⚙️方法：进制字符集
    - 🏷️签名：`bijective_to_num(chars::AbstractString, I::Type{<:Integer}=Int) -> Function`
    - ✨功能：生成一个纯粹的「双射进制转换函数」
      - 即 `bijective_to_num(chars, I)(s)` 等价于 `bijective_to_num(s, chars, I)`
      - 可用于管道和广播操作：`s |> bijective_to_num(chars, I)`、`bijective_to_num(chars, I).([p, q, r])`

## 参考

- 🔗[双射记数系统 - 维基百科](https://zh.wikipedia.org/wiki/%E9%9B%99%E5%B0%84%E8%A8%98%E6%95%B8)
- 🔗[Bijective numeration - Wikipedia](https://en.wikipedia.org/wiki/Bijective_numeration)
