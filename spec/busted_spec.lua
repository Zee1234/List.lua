local List = require('list')

describe('New instances forming', function()
  it('checks that new instances are identical, but not equal', function()
    assert.are.same(List:new(), List:new(), {
      _store = {
        generator = generator;
        n = 0;
        empty = {};
        pairs = {};
      }
    })
    assert.are.unique(List:new(), List:new())
  end)

  it('checks that (de)population occurs correctly', function()
    local function gen(d) return d end
    local listA = List:new(gen):write('1'):write('2'):write('3')
    local listB = List:new(gen):write('1'):write('2'):write('3')
    assert.are.same(listA, listB)

    assert.are.same(listA:remove('1'), listB:remove('1'))
  end)
end)