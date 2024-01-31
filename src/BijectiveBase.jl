# %% Jupyter Notebook | Julia 1.10.0 @ julia | format 2~4
# % language_info: {"file_extension":".jl","mimetype":"application/julia","name":"julia","version":"1.10.0"}
# % kernelspec: {"name":"julia-1.10","display_name":"Julia 1.10.0","language":"julia"}
# % nbformat: 4
# % nbformat_minor: 2

# %% [1] markdown
# # BijectiveBase.jl - 对「双射基数n进制」的解析转换支持

# %% [2] markdown
# 🎯核心功能：对「双射n进制」进行解析、生成
# 
# - 与日常所谓「n进制」的区别：**没有表特殊地位的「0」位值**
#     - 这意味着「A」与「AA」在任何n下语义都不相同

# %% [3] markdown
# <!-- README-end -->
# <!-- TEST-begin -->
# ## 库代码


# %% [5] code
module BijectiveBase


# %% [6] markdown
# ### 代码

# %% [7] markdown
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



# %% [10] markdown
# 计算长度

# %% [11] code
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


# %% [12] markdown
# 数组版本

# %% [13] code
# ! Jupyter允许在单元格中导出符号（而无视模块上下文）
export num_to_bijective, bijective_to_num

"""
    num_to_bijective(x::I, N::U, f::Function, T::Type=Any) -> Vector{T} where {I <: Integer, U <: Integer}
原数→双射进位制数（数组版本）
- ⚠️其中返回的数组对「索引」而言是「从高到底数」的
    - 遵循字面呈现规则，如「双射三进制」下`101`被直译为`[1, 0, 1]`
    - 📌若后续需要扩展，可能需要倒序
"""
function num_to_bijective(x::I, N::U, f::Function, T::Type=Any) where {I <: Integer, U <: Integer}
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
     
"""
    bijective_to_num(s::Vector{T}, N::U, f⁻¹::Function) -> Integer
双射进制数→原数（数组版本）
"""
function bijective_to_num(s::Vector{T}, N::U, f⁻¹::Function) where {T, U <: Integer}
    isempty(s) && return 0
    local l::Integer = length(s)
    return sum(
        f⁻¹(s[l-i]) * N^i
        for i in 0:(l-1)
    )
end


# %% [14] markdown
# 字符串版本

# %% [15] code
# ! 函数已导出，此处只是添加了不同的方法
"""
    num_to_bijective(x::I, chars::AbstractString) where {I <: Integer} -> Integer
原数→双射进位制数（字符串版本）
- 自动以「字符集大小」作为基数
- ⚠️其中返回的数组对「索引」而言是「从高到底数」的
    - 遵循字面呈现规则，如「双射三进制」下`101`即字符串"101"
    - 📌若后续需要扩展，可能需要倒序读取
"""
function num_to_bijective(x::I, chars::AbstractString) where {I <: Integer}
    # ! 通用，无需考虑x=0的情况

    # 通过字串长度获得基数N
    local N = length(chars)

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
        s[n] = chars[c + 1] # 计入
        n -= 1 # 自减
    end

    # 返回最终结果
    return join(s)
end
     
"""
    bijective_to_num(s::AbstractString, chars::AbstractString)
双射进制数→原数（字符串版本）
- 自动以「字符集大小」作为基数
"""
function bijective_to_num(s::AbstractString, chars::AbstractString)
    isempty(s) && return 0
    local N = length(chars)
    local l = length(s)
    return sum(
        findfirst(s[l-i], chars) * N^i
        for i in 0:(l-1)
    )
end



# %% [17] code
end # module

















