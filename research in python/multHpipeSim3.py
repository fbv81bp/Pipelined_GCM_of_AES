def gf_mult(x, y):
    res = 0
    for i in range(127, -1, -1):
        res ^= x * ((y >> i) & 1)  # branchless
        x = (x >> 1) ^ ((x & 1) * 0xE1000000000000000000000000000000)
    return res

H = 0x1234568900000000000000000000abcd
length = 33
stages = 4
values = []
for f in range(length):
    values.append(f)
values[5] = 111
values[17] = 96
values[32] = 51

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
# 2: csökkenő H hatvánnyal MAC-elés
# 3: pipeline kiürítése, elemeinek összegzése

# 1: a maximális H hatvánnyal MAC-elés
for j in range(stages):
    for k in range(length//stages):
        out2[j] = gf_mult(out2[j], Harray[stages-1])
        out2[j] = out2[j] ^ values[j+k*stages]

out3 = 0
p = []
rest = length%stages
for m in range(stages):
    out2[m] = gf_mult(out2[m], Harray[stages-m-1])

#for m2 in range(stages):
    out3 = out3 ^ out2[m]

for n in range(rest): # hátralevő elemek átküldése a pipeline-on eltérő H hatványokkal
    p.append(gf_mult(values[length-rest+n], Harray[rest-n-1]))
if rest != 0:
    out3 = gf_mult(out3, Harray[rest-1])

for q in range(rest): # hátralevő elemek összegzése
    out3 = out3 ^ p[q]

print(hex(out3))

print("--- o ---")
print(out1==out3)
