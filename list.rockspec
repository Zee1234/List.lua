package = "List"
version = "1.0.1-1"
source = {
   url = "git://github.com/Zee1234/List.lua",
}
description = {
  summary = "A list-like class for Lua.",
  homepage = "git://github.com/Zee1234/List.lua",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1, < 5.4"
}
build = {
  type = "builtin",
  modules = {
    list = "src/list.lua"
  }
}