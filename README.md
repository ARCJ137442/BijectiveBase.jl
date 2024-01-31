<!-- ⚠️该文件由 `BijectiveBase.ipynb` 自动生成于 2024-01-31T15:34:08.485，无需手动修改 -->
# BijectiveBase.jl - 对「双射基数n进制」的解析转换支持

## 概述

🎯核心功能：对「双射N进制数值」进行解析、生成

- 与日常所谓「n进制」的区别：**没有表特殊地位的「0」位值**
  - 这意味着「A」与「AA」在任何n下语义都不相同
- 有「数组」「字符串」两种形式可选

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

该Julia包导出了三个函数，分别为

- `length_bijective`：计算数值在「双射进位制」下的位数
  - `length_bijective(x::Integer, N::Integer) -> Integer`：计算数值$x$在「双射$N$进位制」下的位数
  - `length_bijective(x::Integer, chars::AbstractString) -> Integer`：计算数值$x$在以`chars`为$N$进制字符集的「双射$N$进位制」下的位数
- `num_to_bijective`：将数值转换为双射进位制的符号串
  - `num_to_bijective(x::Integer, N::Integer, f::Function) -> Vector`：将数值$x$通过「符号→位值」的映射$f$转换为双射$N$进位制的符号串
  - `num_to_bijective(x::Integer, chars::AbstractString) -> String`：将数值$x$通过指定的「进制字符集」`chars`转换为双射进位制的字符串
- `bijective_to_num`：将双射进位制的数值转换为数值
  - `bijective_to_num(s::Vector, N::Integer, f⁻¹::Function) -> Integer`：将双射$N$进位制的符号串`s`通过「符号→位值」的逆映射$f^{-1}$转换为数值
  - `bijective_to_num(s::AbstractString, chars::AbstractString) -> Integer`：将双射进位制的符号串`s`通过指定的「进制字符集」`chars`转换为数值

## 参考

- 🔗[双射记数系统 - 维基百科](https://zh.wikipedia.org/wiki/%E9%9B%99%E5%B0%84%E8%A8%98%E6%95%B8)
- 🔗[Bijective numeration - Wikipedia](https://en.wikipedia.org/wiki/Bijective_numeration)
