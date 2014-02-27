#!/usr/bin/lua5.2

gausselim = require "gausselim"
primitivepoly = require "primitivepoly"


--Constructs a finite field of order 2^bits
function construct(bits)
   local field = {}
   field.mod = primitivepoly.primitive_polynomials[bits]
   field.bits = bits
   local Polynomial = primitivepoly.Polynomial
   field[1] = setmetatable({1}, Polynomial)
   field[2] = setmetatable({0, 1}, Polynomial)
   for i = 3, 2^bits-1 do
      field[i] = (field[i-1] * field[2]) % field.mod 
   end
   return field
end

function minipoly(field, ele)
   local pfind = gausselim.esearch(field.bits)
   local ret
   local npow = field[ele]
   print("npow: ", table.concat(npow, ", "))
   local z = setmetatable({0}, primitivepoly.Polynomial) --used to force copying npow
   repeat
      print(gausselim.Vector)
      ret = pfind(setmetatable(z+npow, gausselim.Vector))
      npow = (npow * field[ele]) % field.mod
      print("mod: ", table.concat(field.mod, ", "))
      print("npow: ", table.concat(npow, ", "))
   until ret
   print(table.concat(ret, ", "))
   return setmetatable(ret, primitivepoly.Polynomial)
end

--Generates a BCH code generator polynomial
--for a code of length 2^exp and distance dist
function bchpoly(exp, dist)
   local len = 2^exp-1
   if(dist >= len/2) then
      ret = {}
      for i = 1, len do
         ret[i] = 1
      end
      return ret
   end

   local field = construct(exp)
   local mpolys = {field.mod}
   for i = 2, dist-1 do
      mpolys[i] = setmetatable(minipoly(field, i+1), Polynomial)
   end

   local p, zero = setmetatable({1}, primitivepoly.Polynomial), setmetatable({0}, primitivepoly.Polynomial)
   for i = 1, #mpolys do
      print("mpoly:", table.concat(mpolys[i]), "p:", table.concat(p))
      print("remainder:", table.concat(p % mpolys[i]))
      if(p % mpolys[i] ~= zero) then
         p = p * mpolys[i]
      end
   end

   return p
end

return {construct = construct, minipoly = minipoly, bchpoly = bchpoly}
