#!/usr/bin/lua5.2
bch = require"bch"

exp = arg[1] + 0
dist = arg[2] + 0

poly = bch.bchpoly(exp, dist)

s = "1"

for i = 2, #poly do
   if poly[i] == 1 then
      s = "x^" .. (i-1) .. " + " .. s
   end
end

print(s)
