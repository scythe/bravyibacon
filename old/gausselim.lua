
local gausselim = {}

gausselim.Vector = {
__add = function(a, b)
   if(getmetatable(a) ~= getmetatable(b)) then return nil end
   ret = {}
   for i = 1, math.max(#a, #b) do
      ret[i] = ((a[i] or 0) + (b[i] or 0)) % 2
   end
   return setmetatable(ret, getmetatable(a))
end,
__sub = function(a, b)
   return a + b --arithmetic in fields of characteristic two is fun!
end,
__mul = function(a, b)
   if(getmetatable(a) ~= getmetatable(b)) then return nil end
   ret = 0
   for i = 1, math.min(#a, #b) do
      ret = ret + a[i] * b[i]
   end
   return ret % 2
end
}

local function degv(vec)
   for i = 1, #vec do
      if(vec[i] == 1) then 
         vec.deg = i
         return vec.deg
      end
   end
end

--Gaussian elimination search for the kernel of an operator built from row vectors.
--We add a new vector to the matrix and perform Gaussian elimination 
--until an added vector becomess the zero vector. We then return a
--vector in the kernel of the matrix of the original vectors.
function gausselim.esearch(degree)
   local vecs = {}
   return function(vec)
      local deg = degv(vec)
      for i = 1, #vecs do
         vec[degree + i] = 0
      end
      vec[#vecs + degree + 1] = 1
      for i = 1, #vecs do
         if deg < vecs[i].deg then
            table.insert(vecs, i, vec)
            break
         end
         if (vec[vecs[i].deg] == 1) then
            vec = vec + vecs[i]
            deg = degv(vec)
         end
         if (vecs[i][deg] == 1) then 
            vecs[i] = vec + vecs[i]
            vecs[i].deg = degv(vecs[i])
         end
         if(i == #vecs) then
            vecs[#vecs + 1] = vec
            break
         end
      end
      if(#vecs == 0) then
         vecs[1] = vec
      end
      if(deg > degree) then
         ret = {}
         for i = degree + 1, #vec do
            table.insert(ret, vec[i])
         end
         return ret
      end
   end,
   function()
      v = {}
      for i = 1, #vecs do
         for j = 1, degree do
            v[#v+1] = vecs[i][j] or 0
         end
      end
      return v, #vecs, degree
   end
end

return gausselim
