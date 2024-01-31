# 【附加】使用测试代码
using Test

@testset "main" begin
#= %only-compiled
module BijectiveBase
%only-compiled =#

# %ignore-cell
"生成各个进制下所有不同的位值组合"
iter_desc(N, len) = (
    # 初值
    len == 0 ? [] :
    len == 1 ? ([i] for i in 1:N) :
    # 递归
    (
        [i, desc...]
        for i in 1:N # 外层
        for desc in iter_desc(N, len-1) # 里层
    )
)

"""
    num_to_bijective_BRUTE(x, N, f)
暴力转换算法
- 本质是基于「递归」与「计数原理」
- 🎯保证结果正确，为后续作参照
"""
function num_to_bijective_BRUTE(x, N, f)
    x == 0 && return []
    desc_arr = #= Vector{Int} =#[]
    len = 1
    while length(desc_arr) < x
        push!(desc_arr, iter_desc(N, len)...)
        len += 1
    end
    desc_arr[x] .|> f
end

@show iter_desc(3,4) |> collect
[num_to_bijective_BRUTE(i, 2, x -> x-1) for i in 1:16]

# ! Jupyter允许在单元格中导出符号（而无视模块上下文）
#= export导出已忽略 =#

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
# %ignore-below # * 测试代码: 验证长度正确

@test length_bijective.(0:15, 1) == collect(0:15) # 一进制就是堆叠
@test length_bijective.(0:15, 2) == [0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4] # 二进制
@test length_bijective.(0:15, 3) == [0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3] # 三进制
let test(N, range) = @test all(length_bijective.(range, N) .== length.(num_to_bijective_BRUTE.(range, N, identity)))
    for N in 1:10
        range_max = 20 ÷ N
        test(N, 0:range_max)
        @info "长度测试成功！" N range_max
    end
end

# ! Jupyter允许在单元格中导出符号（而无视模块上下文）
#= export导出已忽略 =#

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
# %ignore-below # * 测试代码

# 尝试使用数据框
has_DF = try
    using DataFrames: DataFrame
    true
catch
    @warn "DataFrames包未启用！"
    false
end
# 正式开始
df = let test(N = 2, NUM = 16) = begin
    f(x) = x#-1
    f⁻¹(x) = x#+1
    parseInt(x) = isempty(x) ? 0 : parse(Int, x)

    # 验证空值
    @test isempty(num_to_bijective(0, N, f))
    @test isempty(num_to_bijective_BRUTE(0, N, f))

    # 穷举数据 | 使用广播方法
    range = 1:NUM
    num = N <= 1 ? [nothing for _ in range] : string.(range; base=N)
    len = length_bijective.(range, N)
    @test num_to_bijective.(range, N, f) == num_to_bijective(N, f).(range) # Curly化支持
    arr = num_to_bijective.(range, N, f) .|> Vector{Int}
    @test bijective_to_num.(arr, N, f⁻¹) == bijective_to_num(N, f⁻¹).(arr) # Curly化支持
    arr_B = num_to_bijective_BRUTE.(range, N, f) .|> Vector{Int}
    arr_r = bijective_to_num.(arr, N, f⁻¹)
    # 可选地启用DF进行展示
    df = has_DF ? DataFrame(
        # :i => range,
        :num => num,
        :len => len,
        :arr_B => arr_B,
        :arr => arr,
        :arr_r => arr_r,
        :eq => arr .== arr_B,
    ) : nothing
    @test all(arr .== arr_B) # 与正确的「暴力算法」结果相同
    @test all(arr_r .== range) # 正逆向转换不损失信息
    # df[df[!, :eq] .⊻ true, :]
    has_DF ? df : arr
end
test.([1, 2, 3, 4])
end
# 大数测试
let k = '\u4e00':'\u9fff' |> collect
    N = length(k) # 这里不指定大整数
    f = i -> Char(i + 0x4e00 - 1) # 要把「一」当1
    f⁻¹ = char -> char - '\u4e00' + 1 # 要把「一」当1
    @test k .|> f⁻¹ .|> f == k # 测试映射无损
    @test 0x4e00:0x9fff .|> f .|> f⁻¹ == 0x4e00:0x9fff
    
    # 大数测试1
    let num = big(10)^100 # 指定是大整数
        num_bij = num_to_bijective(num, N, f)
        @test bijective_to_num(num_bij, N, f⁻¹, BigInt#= 指定要转换成大整数 =#) == num # 二轮转换后相等
        @info "大数测试1成功！" num join(num_bij)
    end
    # 大数测试2
    let num_bij = "我是一个字符串" |> collect # 一个字符串序列，转换后是大整数
        num = bijective_to_num(num_bij, N, f⁻¹, BigInt) # 指定要转换成大整数
        @test num_to_bijective(num, N, f) == num_bij # 二轮转换后相等
        @info "大数测试2成功！" num join(num_bij)
    end
end
df

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
# %ignore-begin # *测试 
let s = "一二三四五六七八九十"
    test_set = [
        3 => '三'
        5 => '五'
        9 => '九'
    ]
    for (position, c) in test_set
        @test char_at(s, position) === c
        @test first_index(c, s) == position
    end
end
# %ignore-end

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
# %ignore-below # * 测试代码

# 尝试使用数据框
has_DF = try
    using DataFrames: DataFrame
    true
catch
    @warn "DataFrames包未启用！"
    false
end
# 基础测试
df = let test(chars::AbstractString, NUM = 16) = begin
    N = length(chars)
    parseInt(x) = isempty(x) ? 0 : parse(Int, x)

    # 验证空值
    @test isempty(num_to_bijective(0, chars))
    # @test isempty(num_to_bijective_BRUTE(0, N, chars))

    # 穷举数据 | 使用广播方法 # ! 此处不再与暴力算法作对比
    range = 1:NUM
    num = N <= 1 ? [nothing for _ in range] : string.(range; base=N)
    len = length_bijective.(range, chars)
    arr = num_to_bijective.(range, chars)
    @test num_to_bijective.(range, chars) == num_to_bijective(chars).(range) # Curly化支持
    arr_r = bijective_to_num.(arr, chars)
    @test bijective_to_num.(arr, chars) == bijective_to_num(chars).(arr) # Curly化支持
    eq = arr_r .== range
    # 可选地启用DF进行展示
    df = has_DF ? DataFrame(
        # :i => range,
        :num => num,
        :len => len,
        :arr => arr,
        :arr_r => arr_r, # ! ↓全部相等就不展示了
        (all(eq) ? [] : [:eq => eq])...,
    ) : nothing
    @test all(eq) # 正逆向转换不损失信息
    # df[df[!, :eq] .⊻ true, :]
    has_DF ? df : arr
end
test.(["1", "12", "123", "1234"])
test.(["一", "一二", "一二三", "一二三四"])
end
# 大数测试
let k = String('\u4e00':'\u9fff')
    N = length(k) # 这里不指定大整数
    
    # 大数测试1
    let num = big(10)^100 # 指定是大整数
        num_bij = num_to_bijective(num, k)
        @test bijective_to_num(num_bij, k, BigInt#= 指定要转换成大整数 =#) == num # 二轮转换后相等
        @info "大数测试1成功！" num join(num_bij)
    end
    # 大数测试2
    let num_bij = "我是一个字符串" # 一个字符串序列，转换后是大整数
        num = bijective_to_num(num_bij, k, BigInt) # 指定要转换成大整数
        @test num_to_bijective(num, k) == num_bij # 二轮转换后相等
        @info "大数测试2成功！" num join(num_bij)
    end
end
df

#= %only-compiled
end # module
%only-compiled =#
end
