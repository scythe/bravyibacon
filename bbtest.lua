#!/usr/bin/lua
--The Bravyi-Bacon codes require a matrix with columns and rows that have a large code distance,
--if the columnspace and rowspace of the matrix are treated as classical repetition codes.

--Here we calculate the distance of some candidate matrices.


bvec = {
__add = function(left, right)
   ret = {}
   for i = 1, #left do
      ret[i] = (left[i] + right[i])%2
   end
   return setmetatable(ret, getmetatable(left))
end,
__concat = function(left, right)
   return table.concat(left, " ") .. (right .. "")
end,
__eq = function(left, right)
   for i = 1, #left do
      if(left[i] ~= right[i]) then return false end
   end
   return true
end,
__call = function(self)
   ret = 0
   for i = 1, #self do
      ret = ret + self[i]
   end
   return ret
end
}

function contains(t, v)
   for i = 1, #t do
      if t[i] == v then return true end
   end
   return false
end

function dist(vecs)
   local vs = {}
   for k, v in ipairs(vecs) do
      if(not contains(vs, v)) then
         vs[#vs+1] = v
      end
   end
   local len = #vs
   for i = 1, #vecs do
      for j = i, #vecs do
         local v = vecs[i] + vecs[j]
         if not contains(vs, v) then
            vs[#vs+1] = v
         end
      end
   end
   if len < #vs then
      return dist(vs)
   end
   min = #vs[1]
   for k, v in ipairs(vs) do
      min = v() > 0 and math.min(min, v()) or min   
      print(v .. "")
   end
   return min
end

mat = {
setmetatable({1, 1, 1, 0, 0, 0}, bvec),
setmetatable({1, 0, 0, 1, 1, 0}, bvec),
setmetatable({0, 0, 1, 1, 0, 1}, bvec),
setmetatable({1, 0, 1, 0, 1, 1}, bvec),
setmetatable({0, 1, 1, 1, 1, 0}, bvec),
setmetatable({1, 1, 0, 1, 0, 1}, bvec),
}


print("Code distance is " .. dist(mat))












