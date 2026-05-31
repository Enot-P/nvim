return {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml" },
    settings = {
        yaml = {
            schemaStore = {
                enable = false,
            },
            schemas = {
                ["https://json.schemastore.org/pubspec.json"] = "pubspec.yaml",
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
                    "docker-compose*.yaml",
                    "docker-compose*.yml",
                },
            },
            validate = true,
            completion = true,
        },
    },
}
