--[[
  A table of primitive polynomials of degree n over GF(2).
  These are used to construct BCH codes which can become tangled codes.
  The table extends to 25, a primitive polynomial over GF(2^25) which generates tangled codes
  with O(2^50) qubits. We consider it unlikely that any larger codes will ever be used.
  ]]


primitive_polynomials = {
{0, 1} -- trivial
, {1, 1, 1}
, {1, 1, 0, 1}
, {1, 1, 0, 0, 1}
, {1, 0, 1, 0, 0, 1}
, {1, 1, 0, 0, 0, 0, 1}
, {1, 1, 0, 0, 0, 0, 0, 1}
, {1, 1, 0, 0, 0, 0, 1, 1, 1}
, {1, 0, 0, 0, 1, 0, 0, 0, 0, 1}
, {1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1}
, {1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1}
, {1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1}
, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1}
, {1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
, {1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
}

Polynomial = {
__add = function(p1, p2)
   if(getmetatable(p1) ~= getmetatable(p2)) then return nil end
   ret = {}
   for i = 1, math.max(#p1, #p2) do
      ret[i] = ((p1[i] or 0) + (p2[i] or 0)) % 2
   end
   return setmetatable(ret, getmetatable(p1))
end,
__sub = function(p1, p2)
   if(type(p2) ~= "number") then return nil end
   ret = {}
   for i = 1, p2 do
      ret[i] = 0
   end
   for i = p2+1, p2+#p1 do
      ret[i] = p1[i-p2]
   end
   return setmetatable(ret, getmetatable(p1))
end,
__mul = function(p1, p2)
   if(getmetatable(p1) ~= getmetatable(p2)) then return nil end
   ret = {}
   for i = 1, #p1 + #p2 do
      for j = 1, i do
         ret[i] = ret[i] + (p1[j] or 0) * (p2[i-j+1] or 0)
      end
      ret[i] = ret[i] % 2
   end
   return setmetatable(ret, getmetatable(p1))
end,
__mod = function(p1, p2)
   if(getmetatable(p1) ~= getmetatable(p2)) then return nil end
   ret = p1
   for i = #p1, #p2+1, -1 do
      if(ret[i] > 0) then
         ret = ret + (p2 - (i - #p2))
      end
   end
   return ret
end,
__pow = function(p1, n, mod)
   if(type(n) ~= "number" or n%1 ~= 0 or n < 0) then return nil end
   if(n == 0) then return setmetatable({1}, getmetatable(p1)) end
   if(not mod) then return p1 * (p1^(n-1)) end
   return p1 * (p1^(n-1) % mod)
end,
__call = function(self, p, mod)
   ret = setmetatable({0}, getmetatable(self))
   for i = 1, #self do
      if(i > 0) then
         ret = ret + (getmetatable(p)).__pow(p, i-1, mod)
      end
   end
   return ret
end,
_eq = function(a, b)
   if(getmetatable(a) ~= getmetatable(b)) then return false end
   for i = 1, math.max(#a, #b) do
      if((a[i] or 0) ~= (b[i] or 0)) then return false end
   end
   return true
end }
   
for k, v in ipairs(primitive_polynomials) do
   setmetatable(v, Polynomial)
end

return {primitive_polynomials = primitive_polynomials, Polynomial = Polynomial}


