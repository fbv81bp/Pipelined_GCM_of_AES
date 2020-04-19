def gf_2_128_mul(x, y):
    res = 0
    for i in range(127, -1, -1):
        res ^= x * ((y >> i) & 1)  # branchless
        x = (x >> 1) ^ ((x & 1) * 0xE1000000000000000000000000000000)
    return res

H = 0x32100000000000000000000000000fed
a = 0x100000000000000000d0000000000000
b = 0x20000000000000000c00000000000000
c = 0x3000000000000000b000000000000000
d = 0x400000000000000a0000000000000000
e = 0x5000000000000000000f000000000000

x = gf_2_128_mul(a , H)
x = gf_2_128_mul(x ^ b, H)
x = gf_2_128_mul(x ^ c, H)
x = gf_2_128_mul(x ^ d, H)
x = gf_2_128_mul(x ^ e, H)

print(hex(x))

x1 = gf_2_128_mul(a ,H)
x1 = gf_2_128_mul(x1,H)
x1 = gf_2_128_mul(x1,H)
x1 = gf_2_128_mul(x1,H)
x1 = gf_2_128_mul(x1,H)

x2 = gf_2_128_mul(b ,H)
x2 = gf_2_128_mul(x2,H)
x2 = gf_2_128_mul(x2,H)
x2 = gf_2_128_mul(x2,H)

x3 = gf_2_128_mul(c,H)
x3 = gf_2_128_mul(x3,H)
x3 = gf_2_128_mul(x3,H)

x4 = gf_2_128_mul(d,H)
x4 = gf_2_128_mul(x4,H)

x5 = gf_2_128_mul(e,H)

print(hex(x1^x2^x3^x4^x5))

# (((((a+H)+b)H+c)H+d)h+e)H = aH5+bH4+cH3+dH2+eH
#
# = H.H2(aH2+c)+H.H(bH2+d)+H.e = H(H2(aH2+c)+H(bH2+d)+e)
