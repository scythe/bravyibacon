Vector = {
__add = function(a, b)
   if(getmetatable(a) ~= getmetatable(b)) then return nil end
   ret = {}
   for i = 1, math.max(#a, #b) do
      ret[i] = (a[i] or 0) + (b[i] or 0)
   end
   return ret
end,
__sub = function(a, b)
   return a + b --arithmetic in fields of characteristic two is fun!
end
}

function degv(vec)
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
function esearch(degree)
   local one = setmetatable({1}, Vector)
   for i = 1, degree-1 do
      one[i+1] = 0
   end
   one[degree+1] = 1
   one.deg = 1
   local vecs = {one}
   return function(vec)
      local deg = degv(vec)
      for i = 1, #vecs do
         vec[degree + i] = 0
      end
      vec[#vecs + degree + 1] = 1
      for i = 1, #vecs do
         if deg < vecs[i].deg then
            table.insert(vecs, vec, i)
            break
         end
         if (vec[vecs[i].deg] == 1) then
            vec = vec + vecs[i]
            deg = degv(vec)
         end
         if(i == #vecs) then
            vecs[#vecs + 1] = vec
            break
         end
      end
      if(deg > degree) then
         ret = {}
         for i = degree + 1, #vec do
            table.insert(ret, vec[i])
         end
         return ret
      end
   end
end

return {Vector = Vector, esearch = esearch}
