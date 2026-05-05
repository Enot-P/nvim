return {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml" },
    settings = {
        yaml = {
            schemaStore = {
                enable = false,
            },
            schemas = {
                ["https://www.schemastore.org/pubspec.json"] = "pubspec.yaml",
            },
            validate = true,
            completion = true,
        },
    },
}
