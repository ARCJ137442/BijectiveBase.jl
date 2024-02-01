# %% Jupyter Notebook | Julia 1.10.0 @ julia | format 2~4
# % language_info: {"file_extension":".jl","mimetype":"application/julia","name":"julia","version":"1.10.0"}
# % kernelspec: {"name":"julia-1.10","display_name":"Julia 1.10.0","language":"julia"}
# % nbformat: 4
# % nbformat_minor: 2

# %% [1] markdown
# # BijectiveNumeration.jl

# %% [2] markdown
# [![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
# [![Static Badge](https://img.shields.io/badge/julia-package?logo=julia&label=1.4%2B)](https://julialang.org/)
# 
# [![CI status](https://github.com/ARCJ137442/BijectiveNumeration.jl/workflows/CI/badge.svg)](https://github.com/ARCJ137442/BijectiveNumeration.jl/actions/workflows/ci.yml)
# [![codecov](https://codecov.io/gh/ARCJ137442/BijectiveNumeration.jl/graph/badge.svg?token=PCQHEU15L0)](https://codecov.io/gh/ARCJ137442/BijectiveNumeration.jl)
# 
# 该项目使用[语义化版本 2.0.0](https://semver.org/)进行版本号管理。

# %% [3] markdown
# ## 概述

# %% [4] markdown
# 🎯核心功能：为「双射进位制」提供**解析、转换**支持
# 
# - 有「数组」「字符串」两种形式可选
#     - 数组形式更为通用
#     - 字符串形式更为常用
# 
# 📌概念「双射进位制」
# 
# - 与常规「N进制数值」的区别：**没有表特殊地位的「0」位值**
#     - 这意味着「A」与「AA」在任何N下语义都不相同
#     - 🔗细节可参看[下表](#对照表)

# %% [5] markdown
# ## 对照表

# %% [6] markdown
# 部分二进制数的对应关系表如下：
# 
# | 原 | BIN | Bijective BIN | 权值显示 |
# | ---: | ---: | ---: | ---: |
# | 0 | 0 |  |  |
# | 1 | 1 | 0 | 1 |
# | 2 | 10 | 1 | 2 |
# | 3 | 11 | 00 | 21 |
# | 4 | 100 | 01 | 22 |
# | 5 | 101 | 10 | 41 |
# | 6 | 110 | 11 | 42 |
# | 7 | 111 | 000 | 421 |
# | 8 | 1000 | 001 | 422 |
# | 9 | 1001 | 010 | 441 |
# | 10 | 1010 | 011 | 442 |
# | 11 | 1011 | 100 | 821 |
# | 12 | 1100 | 101 | 822 |
# | 13 | 1101 | 110 | 841 |
# | 14 | 1110 | 111 | 842 |
# | 15 | 1111 | 0000 | 8421 |
# | $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ |
# 
# ^其中**空白单元格**表示「空字符串」

# %% [7] markdown
# ## 使用

# %% [8] markdown
# ### 代码概览

# %% [9] markdown
# 该Julia包导出了三个函数，分别为
# 
# - 📌`length_bijective`：**计算数值在「双射进位制」下的位数**
#     - ⚙️方法：指定进制
#         - 🏷️签名：`length_bijective(x::Integer, N::Integer) -> Integer`
#         - ✨功能：计算数值`x`在「双射`N`进位制」下的位数
#     - ⚙️方法：指定进制字符集
#         - 🏷️签名：`length_bijective(x::Integer, chars::AbstractString) -> Integer`
#         - ✨功能：计算数值`x`在以`chars`为`N`进制字符集的「双射`N`进位制」下的位数
# - 📌`num_to_bijective`：**将数值转换为双射进位制的符号串**
#     - ⚙️方法：基数+映射
#         - 🏷️签名：`num_to_bijective(x::Integer, N::Integer, f::Function=identity, T::Type=Any) -> Vector{T}`
#         - ✨功能：将数值`x`通过「符号→位值」的映射`f`转换为双射`N`进位制的符号串
#         - 🔧参数：映射`f`
#             - 默认：恒等函数`identity`，即使用**1~N**作为符号值
#     - ⚙️方法：进制字符集
#         - 🏷️签名：`num_to_bijective(x::Integer, chars::AbstractString) -> String`
#         - ✨功能：将数值`x`通过指定的「进制字符集」`chars`转换为双射进位制的字符串
# - 📌`bijective_to_num`：**将双射进位制符号串解析为数值**
#     - ⚙️方法：基数+映射
#         - 🏷️签名：`bijective_to_num(s::Vector, N::Integer, f⁻¹::Function=identity, I::Type{<:Integer}=Int) -> I`
#         - ✨功能：将双射`N`进位制的符号串`s`通过「符号→位值」的逆映射`f⁻¹`转换成类型为I的数值
#         - 🔧参数：映射`f`
#             - 默认：恒等函数`identity`，即使用**1~N**作为符号值
#         - 🔧参数`I`：输出的整数类型
#             - 填写`BigInt`以兼容大整数`BigInt`
#             - 默认：`Int`
#     - ⚙️方法：进制字符集
#         - 🏷️签名：`bijective_to_num(s::AbstractString, chars::AbstractString, I::Type{<:Integer}=Int) -> I`
#         - ✨功能：将双射进位制的符号串`s`通过指定的「进制字符集」`chars`转换成类型为I的数值
#         - 🔧参数`I`：输出的整数类型
#             - 填写`BigInt`以兼容大整数`BigInt`
#             - 默认：`Int`

# %% [10] markdown
# 对函数参数Curly化的支持：
# 
# - 📌`num_to_bijective`
#     - ⚙️方法：基数+映射
#         - 🏷️签名：`num_to_bijective(N::Integer, f::Function=identity, T::Type=Any) -> Function`
#         - ✨功能：生成一个纯粹的「双射进制转换函数」
#             - 即 `num_to_bijective(N, f, T)(x)` 等价于 `num_to_bijective(x, N, f, T)`
#             - 可用于管道和广播操作：`x |> num_to_bijective(N, f, T)`、`num_to_bijective(N, f, T).([x, y, z])`
#     - ⚙️方法：进制字符集
#         - 🏷️签名：`num_to_bijective(chars::AbstractString, args...) -> Function`
#         - ✨功能：生成一个纯粹的「双射进制转换函数」
#             - 即 `num_to_bijective(chars, args...)(x)` 等价于 `num_to_bijective(x, chars, args...)`
#             - 可用于管道和广播操作：`x |> num_to_bijective(chars, args...)`、`num_to_bijective(chars, args...).([x, y, z])`
# - 📌`bijective_to_num`
#     - ⚙️方法：进制+映射
#         - 🏷️签名：`bijective_to_num(N::Integer, f⁻¹::Function=identity, I::Type{<:Integer}=Int) -> Function`
#         - ✨功能：生成一个纯粹的「双射进制转换函数」
#             - 即 `bijective_to_num(N, f⁻¹, I)(s)` 等价于 `bijective_to_num(s, N, f⁻¹, I)`
#             - 可用于管道和广播操作：`s |> bijective_to_num(N, f⁻¹, I)`、`bijective_to_num(N, f⁻¹, I).([p, q, r])`
#     - ⚙️方法：进制字符集
#         - 🏷️签名：`bijective_to_num(chars::AbstractString, I::Type{<:Integer}=Int) -> Function`
#         - ✨功能：生成一个纯粹的「双射进制转换函数」
#             - 即 `bijective_to_num(chars, I)(s)` 等价于 `bijective_to_num(s, chars, I)`
#             - 可用于管道和广播操作：`s |> bijective_to_num(chars, I)`、`bijective_to_num(chars, I).([p, q, r])`

# %% [11] markdown
# ## 参考

# %% [12] markdown
# - 🔗[双射记数系统 - 维基百科](https://zh.wikipedia.org/wiki/%E9%9B%99%E5%B0%84%E8%A8%98%E6%95%B8)
# - 🔗[Bijective numeration - Wikipedia](https://en.wikipedia.org/wiki/Bijective_numeration)

# %% [13] markdown
# <!-- README-end -->
# <!-- TEST-begin -->
# ## 库代码


# %% [15] code
module BijectiveNumeration


# %% [16] markdown
# ### 代码

# %% [17] markdown
# 📌教训：对此类「数值找规律」的问题，一定要善用**🛠️表格对照法**
# 
# - ❌闷头写算法：仅凭少量样例编写算法，容易导致过拟合（面对新例出现异常）
# - ❌瞎蒙改代码：仅凭一时直觉修改试错，往往思路难拟合（按下葫芦又浮起瓢）
# 
# | 原 | BIN | Bijective BIN | $\lceil \log_2 原 \rceil$ | `length(bi-bin)` | 权值显示 |
# | ---: | ---: | ---: | ---: | ---: | ---: |
# | 0 | 0 |  |  |  |  |
# | 1 | 1 | 0 | 1 | 1 | 1 |
# | 2 | 10 | 1 | 1 | 1 | 2 |
# | 3 | 11 | 00 | 2 | 2 | 21 |
# | 4 | 100 | 01 | 2 | 2 | 22 |
# | 5 | 101 | 10 | 3 | 2 | 41 |
# | 6 | 110 | 11 | 3 | 2 | 42 |
# | 7 | 111 | 000 | 3 | 3 | 421 |
# | 8 | 1000 | 001 | 3 | 3 | 422 |
# | 9 | 1001 | 010 | 4 | 3 | 441 |
# | 10 | 1010 | 011 | 4 | 3 | 442 |
# | 11 | 1011 | 100 | 4 | 3 | 821 |
# | 12 | 1100 | 101 | 4 | 3 | 822 |
# | 13 | 1101 | 110 | 4 | 3 | 841 |
# | 14 | 1110 | 111 | 4 | 3 | 842 |
# | 15 | 1111 | 0000 | 4 | 4 | 8421 |
# | $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ | $\vdots$ |



# %% [20] markdown
# 计算长度

# %% [21] code
# ! Jupyter允许在单元格中导出符号（而无视模块上下文）
export length_bijective

"""
    length_bijective(x::I, N) -> Integer where {I <: Integer}
计算「双射进位制数」的长度（基数版）
- @param x 需要转换的数值
- @param N 进制基数
- @returns 所转换成的「双射N进位数」的基数
"""
function length_bijective(x::I, N::U) where {I <: Integer, U <: Integer}
    local n::I = 0
    local y::I = x
    while y >= N^n
        y -= N^n
        n += 1
    end
    return n
end
"""
    length_bijective(x, chars::AbstractString) -> Integer
计算「双射进位制数」的长度（字符串版）
- @param x 需要转换的数值
- @param chars 进制字符集
- @returns 🔗以「字符集大小」为进制基数
"""
length_bijective(x, chars::AbstractString) = length_bijective(x, length(chars))


# %% [22] markdown
# 数组版本

# %% [23] code
# ! Jupyter允许在单元格中导出符号（而无视模块上下文）
export num_to_bijective, bijective_to_num

"""
    num_to_bijective(x::I, N::U, f::Function, T::Type=Any) -> Vector{T} where {I <: Integer, U <: Integer}

原数→双射进位制数（数组版本）
- @param x 要转换的原数
- @param N 进制基数
    - 类型提升主要发生在`x`上，兼容大整数只需传入`x::BigInt`即可
- @param f 「权值→符号」的映射函数
    - @default `f`为`identity`，即默认为「1~N」的数值串
- @param T 「双射N进位数」的符号类型
    - @default 一般情况下，`T`为`Any`
    - ⚠️除非指定类型`T`，否则不对数组元素类型进行约束
- @return 「双射N进位数」符号串（数组）
    - ⚠️其对「索引」而言是「从高到底数」的
        - 遵循字面呈现规则，如「双射三进制」下`121`被直译为`[1, 2, 1]`
        - 📌若后续需要扩展，可能需要倒序
"""
function num_to_bijective(x::I, N::Integer, f::Function=identity, T::Type=Any) where {I <: Integer}
    # ! 通用，无需考虑x=0的情况

    # 减去1111，并得到长度 | 将「1~N」问题 转换为 「0~(N-1)」问题
    local n::I = 0
    local y::I = x
    while y >= N^n
        y -= N^n
        n += 1
    end

    # 将y按照常规的「除N取余」来做 | 已转换为「0~(N-1)」问题
    local s::Vector{T} = Vector{T}(undef, n)
    local c::I
    while n > 0
        y, c = divrem(y, N) # 除N取余
        s[n] = f(c + 1) # 计入
        n -= 1 # 自减
    end

    # 返回最终结果
    return s
end

"参数Curly化支持"
num_to_bijective(N::Integer, f::Function=identity, T::Type=Any) = x -> num_to_bijective(x, N, f, T)

"""
    bijective_to_num(s::Vector{T}, N::U, f⁻¹::Function) -> Integer

双射进制数→原数（数组版本）
- @param s 「双射N进位数」符号串（数组）
- @param N 进制基数
- @param f⁻¹ 「符号→权值」的映射函数
    - @default `f⁻¹`为`identity`，即默认为「1~N」的数值串
- @param [I] 转换结果（原数）的类型
    - 用于兼容大整数
"""
function bijective_to_num(s::Vector{T}, N::U, f⁻¹::Function=identity) where {T, U <: Integer}
    # 初始化总和
    local result::U = zero(U)
    
    # ! 通用，无需考虑s为空的情况
    local l = length(s)

    # 逐位求和
    for i in 0:(l-1)
        result += f⁻¹(s[l-i]) * N^i
    end
    return result
end

"类型默认参数"
bijective_to_num(s::Vector, N::Integer, f⁻¹::Function, I::Type{<:Integer}) = bijective_to_num(s, I(N), f⁻¹)

"参数Curly化支持"
bijective_to_num(N::Integer, f⁻¹::Function=identity, I::Type{<:Integer}=Int) = s -> bijective_to_num(s, N, f⁻¹, I)


# %% [24] markdown
# 字符串版本

# %% [25] code
# * 一些工具函数

"【内部】获取指定*位置*的字符（无视Unicode多字节限制）"
@inline char_at(s::AbstractString, position::Integer) = s[nextind(s, 0, position)]

"【内部】根据字符获取首次出现的*位置*"
function first_index(s::AbstractString, c::AbstractChar)
    local i = firstindex(s)
    local position = 1
    while i <= lastindex(s)
        # 相等⇒返回
        s[i] === c && return position
        # 否则⇒递增
        i = nextind(s, i)
        position += 1
    end
    return nothing
end
"反过来也行"
first_index(c::AbstractChar, s::AbstractString) = first_index(s, c)

# ! 函数已导出，此处只是添加了不同的方法

"""
    num_to_bijective(x::I, chars::AbstractString) where {I <: Integer} -> Integer

原数→双射进位制数（字符串版本）
- @param x 原数
- @param chars 双射进制数字符集
    - 自动以「字符集大小」作为基数N
- @param [I] 原数类型（可选约束）
- @return 双射进制数符号串（字符串）
    - ⚠️其中返回的数组对「索引」而言是「从高到底数」的
        - 遵循字面呈现规则，如「双射三进制」下`101`即字符串"101"
    - 📌若后续需要扩展，可能需要倒序读取
"""
function num_to_bijective(x::I, chars::AbstractString) where {I <: Integer}
    # ! 通用，无需考虑x=0的情况

    # 通过字串长度获得基数N
    local N::I = length(chars)

    # 减去1111，并得到长度 | 将「1~N」问题 转换为 「0~(N-1)」问题
    local n::I = 0
    local y::I = x
    while y >= N^n
        y -= N^n
        n += 1
    end

    # 将y按照常规的「除N取余」来做 | 已转换为「0~(N-1)」问题
    local s::Vector{Char} = Vector{Char}(undef, n)
    local c::I
    while n > 0
        y, c = divrem(y, N) # 除N取余
        s[n] = char_at(chars, c+1) # 计入
        n -= 1 # 自减
    end

    # 返回最终结果
    return join(s)
end

"默认类型参数"
num_to_bijective(x::Integer, chars::AbstractString, I::Type{<:Integer}) = num_to_bijective(I(x), chars)

"参数Curly化支持"
num_to_bijective(chars::AbstractString, args...) = x -> num_to_bijective(x, chars, args...)
     
"""
    bijective_to_num(s::AbstractString, chars::AbstractString)

双射进制数→原数（字符串版本）
- @param s 双射进制数符号串（字符串）
- @param chars 双射进制数字符集
    - 自动以「字符集大小」作为基数N
- @param [I] 原数类型（可选约束）
- @return 原数
"""
function bijective_to_num(s::AbstractString, chars::AbstractString, ::Type{I}) where {I <: Integer}
    local result::I = zero(I)
    # 正常求和 | # ! 通用方法，因l=0不执行`for`故无需提前判断
    local N::I = length(chars)
    local l = length(s)
    for i in 0:(l-1)
        result += first_index(chars, char_at(s, l-i)) * N^i
    end
    return result
end

"默认类型参数"
bijective_to_num(s::AbstractString, chars::AbstractString) = bijective_to_num(s, chars, Int) # 默认为Int类型

"参数Curly化支持"
bijective_to_num(chars::AbstractString, I::Type{<:Integer}=Int) = s -> bijective_to_num(s, chars, I)



# %% [27] code
end # module

















