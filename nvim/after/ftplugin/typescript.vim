setlocal define=\\(const\\\|let\\\|private\\\|public\\\|class\\)
setlocal iskeyword+=$
setlocal suffixesadd+=.js,.tsx,.jsx
setlocal path+=$PWD/node_modules
