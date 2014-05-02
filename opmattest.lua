#!/usr/bin/lua5.2
opmat = require "opmat"
matmul = require "matmul"

--ghetto database
code = require(arg[1])

codenum = opmat.enumerators(code)

print(codenum, codenum.rank)
xs, xl = opmat.xstab(codenum)
zg = opmat.zgauge(codenum)
zs, zl = opmat.zstab(codenum)
xg = opmat.xgauge(codenum)

print(#xs .. "#xs")
for i = 1, #xs do 
   print("xs[" .. i .. "] " .. table.concat(xs[i], " "))
end

for i = 1, #xl do
   print("xl[" .. i .. "] " .. table.concat(xl[i], " "))
end

for i = 1, #xg do
   print("xg[" .. i .. "] " .. table.concat(xg[i], " "))
end

for i = 1, #zs do 
   print("zs[" .. i .. "] " .. table.concat(zs[i], " "))
end

for i = 1, #zl do
   print("zl[" .. i .. "] " .. table.concat(zl[i], " "))
end

for i = 1, #zg do
   print("zg[" .. i .. "] " .. table.concat(zg[i], " "))
end
