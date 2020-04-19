out1 = 0
for i in range(32):
    out1 = out1 + i
    out1 = out1 * 117
print(out1)

out2 = [0,0,0,0]
for j in range(4):
    for k in range(8):
        out2[j] = out2[j] * 117**4
        out2[j] = out2[j] + (k*4+j)

out3 = 0
for m in range(4):
    out3 = out3 + out2[m]
    out3 = out3 * 117

print(out3)