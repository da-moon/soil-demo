  " install coc extensions
let g:coc_extensions = [
  \ 'coc-marketplace',
  \ 'coc-docker',
  \ 'coc-sh',
  \ 'coc-vimlsp',
  \ 'coc-markdownlint',
  \ 'coc-tabnine',
  \ 'coc-todolist',
  \ 'coc-spell-checker',
  \ 'coc-cspell-dicts',
  \ 'coc-grammarly',
  \ 'coc-json',
  \ 'coc-format-json',
  \ 'coc-yaml',
  \ 'coc-tasks',
  \ 'coc-fzf-preview',
  \ 'coc-reveal',
\]

let g:coc_preferences = {
  \ "autoTrigger": "always",
  \ "maxCompleteItemCount": 10,
  \ "codeLens.enable": 1,
  \ "diagnostic.virtualText": 1,
\}
let g:coc_start_at_startup    = 1
let g:coc_force_debug = 1

let g:coc_disable_startup_warning = 1
let g:UltiSnipsExpandTrigger = "<nop>"

function! before#coc#common#bootstrap()
  call SpaceVim#logger#info("[ before#coc#common ] bootstrap function called.")
  call SpaceVim#logger#info("[ before#coc#common ] binding coc-nvim group to 'C'.")
  call SpaceVim#custom#SPCGroupName(['C'], '+Coc-nvim')
  call SpaceVim#custom#SPC('nore', ['C', 'h'], 'ShowDoc', 'Show current symbol help', 1)
  call SpaceVim#custom#SPC('nore', ['C', 'r'], 'Refactor', 'Open coc-refactor window', 1)
  call SpaceVim#custom#SPC('nore', ['C', 'n'], 'RenameSym', 'Rename cword symbol', 1)
  call SpaceVim#custom#SPC('nore', ['C', 'R'], 'CocCommand workspace.renameCurrentFile', 'Rename current file ,update imports', 1)
endfunction
