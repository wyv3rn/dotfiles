-- Snippets via registers
vim.fn.setreg("i", "\\begin\022{itemize\022}\r\\end\022{itemize\022}\027Vk=o\\item ", "c")
vim.fn.setreg("e", "\\begin\022{enumerate\022}\r\\end\022{enumerate\022}\027Vk=o\\item ", "c")
vim.fn.setreg("m", "\\begin\022{equation\022}\r\\end\022{equation\022}\027Vk=o", "c")
