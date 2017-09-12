-- Copyright (c) 2017 Zee1234

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


local insert, remove = table.insert, table.remove


local List = {}
List.__index = function(tab, key)
  return rawget(List, key) or (tab._store.pairs[key] and tab[tab._store.pairs[key]])
end




function List.new(generator)
  generator = generator or function(_,i)
    return tostring(i)
  end

  local obj = setmetatable({}, List)

  obj._store = {
    generator = generator;
    n = 0;
    empty = {};
    pairs = {};
  }

  return obj
end











function List:write(data)
  local index
  if self._store.empty[1] then
    index = self._store.empty[1]
  else
    index = self._store.n + 1
  end

  local id = self._store.generator(data, index)
  if type(id) == 'number' then id = tostring(id) end
  if self[id] and self[id] ~= false then
    -- return 'error'
    return nil, 'Tried to enter seemingly duplicate data'
  end

  if self._store.empty[1] then
    remove(self._store.empty,1)
    self._store.empty[tostring(index)] = nil
  else
    self._store.n = self._store.n + 1
  end

  self[index] = data
  self._store.pairs[id] = index

  return self
end











function List:remove(uid)
  if not self[uid] and self[uid] ~= false then
    -- return 'error'
    return nil, 'Tried to remove a non-member'
  end

  local index, id
  if type(uid) == 'number' then
    index = uid
    id = self._store.generator(self[index],index)
  else
    id = uid
    index = self._store.pairs[id]
  end

  do
    local empty = self._store.empty
    local i = #empty
    if not empty[i] or empty[i] < index then
      insert(empty, index)
      empty[tostring(index)] = 1
    else
      repeat
        i = i - 1
        if not empty[i] or empty[i] < index then
          insert(empty, i+1, index)
          empty[tostring(index)] = i+1
          break;
        end
      until i == 0
    end
  end

  self._store.pairs[id] = nil
  self[index] = nil

  return self
end










function List:removeReturn(uid)
  if not self[uid] and self[uid] ~= false then
    -- return 'error'
    return nil, 'Tried to remove a non-member'
  end
  local save = self[uid]
  self:remove(uid)
  return save
end










function List:getIndex(id)
  return self._store.pairs[id]
end











function List:next(prev)
  local index = prev + 1
  local value, id
  local done = false
  repeat
    if self[index] then
      value = self[index]
      id = self._store.generator(self[index],index)
      done = true
    elseif self._store.empty[tostring(index)] then
      index = index + 1
    else
      index = nil
      done = true
    end
  until done
  return index, value, id
end

function List:iterate()
  return self.next, self, 0
end



return List