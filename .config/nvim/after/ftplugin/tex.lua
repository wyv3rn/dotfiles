-- Snippets via registers
vim.fn.setreg("i", "i\\begin\022{itemize\022}\027o\\end\022{itemize\022}\027Vk=o\\item ", "c")
vim.fn.setreg("e", "i\\begin\022{enumerate\022}\027o\\end\022{enumerate\022}\027Vk=o\\item ", "c")
vim.fn.setreg("m", "i\\begin\022{equation\022}\027o\\end\022{equation\022}\027Vk=o", "c")
vim.fn.setreg("f", "i\\begin\022{figure\022}\027o\\end\022{figure\022}\027Vk=o\\centering\027o\\includegraphics[width=1.0\\linewidth]\022{\022}\027o\\caption{}\027o\\label\022{\022}\027kkf{a", "c")
