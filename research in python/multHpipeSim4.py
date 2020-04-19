def gf_mult(x, y):
    res = 0
    for i in range(127, -1, -1):
        res ^= x * ((y >> i) & 1)  # branchless
        x = (x >> 1) ^ ((x & 1) * 0xE1000000000000000000000000000000)
    return res

H = 0x1234568900000000000000000000abcd
length = 35
stages = 5
values = []
for f in range(length):
    values.append(f)
values[5]  = 11
values[17] = 1096
values[32] = 514

print("--- o ---")
out1 = 0
for g in range(length):
    out1 = out1 ^ values[g]
    out1 = gf_mult(out1, H)
print(hex(out1))

print("--- o ---")
out2 = []
Harray = []
Htmp = H
for i in range(stages):
    out2.append(0)
    Harray.append(Htmp)
    Htmp = gf_mult(Htmp, H)

# 3x FOR-ból meg kell tudni oldani:
# 1: a maximális H hatvánnyal MAC-elés
# 2: a maradék minta és a már meglevő rész összegek csökkenő H hatvánnyal MAC-elése
# 3: pipeline kiürítése, elemeinek összegzése

# 1: a maximális H hatvánnyal MAC-elés (run)
for j in range(stages):
    for k in range(length//stages):
        out2[j] = gf_mult(out2[j], Harray[-1])
        out2[j] = out2[j] ^ values[j+k*stages]

# 2: a maradék minta és a már meglevő rész összegek csökkenő H hatvánnyal MAC-elése (finalize)
rest = length%stages
# utolsó 8 minta H hatványai: 8=5+3 7=5+2 6=5+1 5 4 (3 2 1)
for m in range(rest):
    out2[m] = gf_mult(out2[m], Harray[-1])
    out2[m] = out2[m] ^ values[length-rest+m]

for n in range(stages): 
    out2[n] = gf_mult(out2[n], Harray[rest-n-1]) 

# 3: pipeline kiürítése, elemeinek összegzése (flush)
out3 = 0
for p in range(stages):
    out3 = out3 ^ out2[p]

print(hex(out3))

print("--- o ---")
print(out1==out3)
