set rtp+=.
set rtp+=~/.local/share/nvim/lazy/plenary.nvim/
set rtp+=~/Documents/auto-k8s.nvim/

runtime! plugin/plenary.vim
lua << EOF
  local test_setup = require('tests.test_setup')
EOF
