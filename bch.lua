#!/usr/bin/lua5.2

gausselim = require "gausselim"
primitivepoly = require "primitivepoly"

local bch = {}

--Constructs a finite field of order 2^bits
function bch.construct(bits)
   print("running construct()")
   local field = {}
   field.mod = primitivepoly.primitive_polynomials[bits]
   print(type(field), type(field.mod), bits, type(bits))
   field.bits = bits
   local Polynomial = primitivepoly.Polynomial
   field[1] = setmetatable({1}, Polynomial)
   field[2] = setmetatable({0, 1}, Polynomial)
   for i = 3, 2^bits-1 do
      field[i] = (field[i-1] * field[2]) % field.mod 
   end
   return field
end

function bch.minipoly(field, ele)
   local pfind = gausselim.esearch(field.bits)
   local ret
   local npow = setmetatable({1}, primitivepoly.Polynomial)
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
function bch.bchpoly(exp, dist)
   local len = 2^exp-1
   if(dist >= len/2) then
      ret = {}
      for i = 1, len do
         ret[i] = 1
      end
      return ret
   end

   print("going to run construct()", type(construct))
   local field = bch.construct(exp)
   print(type(field))
   local mpolys = {field.mod}
   for i = 2, dist-1 do
      mpolys[i] = setmetatable(bch.minipoly(field, i+1), primitivepoly.Polynomial)
   end

   local p, zero = setmetatable({1}, primitivepoly.Polynomial), setmetatable({0}, primitivepoly.Polynomial)
   for i = 1, #mpolys do
      print(i, "mpoly:", table.concat(mpolys[i]), "p:", table.concat(p), getmetatable(mpolys[i]), getmetatable(p))
      print("remainder:", table.concat(p % mpolys[i]))
      if(p % mpolys[i] ~= zero) then
         p = p * mpolys[i]
      end
   end

   return p
end

return bch
