function! Reload() abort
	lua for k in pairs(package.loaded) do if k:match("^.") then package.loaded[k] = nil end end
	lua require(".")
endfunction

nnoremap rr :call Reload()<CR>
