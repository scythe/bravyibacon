#!/usr/local/bin/luajit

gausselim = require "gausselim"
primitivepoly = require "primitivepoly"

local bch = {}

--Constructs a finite field of order 2^bits
function bch.construct(bits)
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

function bch.minipoly(field, ele)
   local pfind = gausselim.esearch(field.bits)
   local ret
   local npow = setmetatable({1}, primitivepoly.Polynomial)
   local z = setmetatable({0}, primitivepoly.Polynomial) --used to force copying npow
   repeat
      ret = pfind(setmetatable(z+npow, gausselim.Vector))
      npow = (npow * field[ele]) % field.mod
   until ret
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

   local field = bch.construct(exp)
   local mpolys = {field.mod}
   for i = 2, dist-1 do
      mpolys[i] = setmetatable(bch.minipoly(field, i+1), primitivepoly.Polynomial)
   end

   local p, zero = setmetatable({1}, primitivepoly.Polynomial), setmetatable({0}, primitivepoly.Polynomial)
   for i = 1, #mpolys do
      if(p % mpolys[i] ~= zero) then
         p = p * mpolys[i]
      end
   end

   return p
end

return bch
