-- Линтер golangci-lint как отдельный LSP (gopls несёт только staticcheck).
-- Подхватывает .golangci.yml/.golangci.yaml проекта — те же правила, что и в CI.
-- Требует бинари: golangci-lint (v2) и golangci-lint-langserver.
return {
    name = "golangci_lint_ls",
    cmd = { "golangci-lint-langserver" },
    filetypes = { "go", "gomod" },
    root_markers = { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json", "go.work", "go.mod", ".git" },
    init_options = {
        -- v2-синтаксис: вывод JSON в stdout (в v1 был --out-format json).
        command = {
            "golangci-lint",
            "run",
            "--output.json.path=stdout",
            "--show-stats=false",
            "--issues-exit-code=1",
        },
    },
}
