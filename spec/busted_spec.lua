local List = require('list')

local function genericGenerator(_, d) return d end -- Identical to List's default generator
local function gen(d) return d end -- Returns all data to use as key, good for testing

describe('New instances', function()
  it('are checked to be identical, but not equal', function()
    assert.are.same(List.new(genericGenerator), List.new(genericGenerator), {
      _store = {
        generator = genericGenerator;
        n = 0;
        empty = {};
        pairs = {};
      }
    })

    assert.are.unique(List.new(genericGenerator), List.new(genericGenerator))
  end)
end)


describe('With new instances,', function()
  it('checks that (de)population occurs identically', function()
    local listA = List.new(gen):write('1'):write('2'):write('3')
    local listB = List.new(gen):write('1'):write('2'):write('3')
    assert.are.same(listA, listB)

    assert.are.same(listA:remove('1'), listB:remove('1'))
  end)
end)

describe('Chained methods', function()
  it('continue to function if no error', function()
    assert.is.truthy(
      List.new(gen)
          :write('a')
          :write('b')
          :write('c')
          :write('d')
          :remove('d')
          :remove(3)
          :write('c')
          :write('d')
    )
  end)

  it('insert into removed spaces properly', function()
    local listA = List.new(gen)
                      :write('a')
                      :write('b')
                      :write('c')
                      :write('d')
                      :remove('b')
                      :remove('c')
                      :write('e')
    local store = listA._store
    assert.are.same(listA, {
      'a', 'e', nil, 'd', _store = store
    })
  end)
end)

describe('`removeReturn`', function()

  it('removes properly',function() 
    local listA = List.new(gen):write('a')
    local ret = listA:removeReturn('a')
    local store = listA._store
    assert.are.same(listA, {
      _store = store
    })
  end)

  it('returns properly', function()
    local listA = List.new(gen):write('a')
    local arbitrary = {
      [math.random()] = math.random();
      [math.random()] = math.random();
    }
    listA:write(arbitrary)
    local ret = List:removeReturn(2)

    local listB = List.new(gen):write('a')
    listB:write('b'):remove('b')

    assert.are.same(listA, listB)
  end)
end)