-- atlas.nvim -- ревью пул-реквестов не выходя из редактора.
-- В отличие от плагинов вокруг ката, стоит на официальных API, а не на
-- скрейпинге: GitHub идёт через `gh` CLI, так что токен плагин не видит и не
-- хранит -- им занимается сам CLI (у нас он лежит в keyring).
vim.pack.add({
    {
        src = "https://github.com/emrearmagan/atlas.nvim",
        -- README прямым текстом предупреждает про early development, а темп --
        -- 551 коммит за семь месяцев. Держимся ветки тегов 0.7.x, чтобы
        -- обновление не приезжало ломающим посреди ревью.
        version = vim.version.range("0.7"),
    },
})

require("atlas").setup({
    ui = {
        -- "auto" всё равно выбрал бы snacks, но telescope тут тоже стоит --
        -- лучше сказать явно, чем зависеть от порядка резолва.
        picker = "snacks",
    },

    providers = {
        -- Только GitHub: для GitLab/Bitbucket/Jira нужны PAT в окружении
        -- (GITLAB_TOKEN и компания), а их нет. Добавить провайдера = завести
        -- переменную и дописать сюда таблицу.
        github = {
            cache_ttl = 300,
        },
    },
})

-- Клавиши: `<leader>g` уже забит гитом под завязку, поэтому Atlas живёт на
-- своём префиксе. Внутри его буферов работают собственные маппинги плагина,
-- подсказки к ним показывает его статуслайн.
local map = vim.keymap.set

vim.keymap.set("n", "<leader>r", "", { desc = "+atlas (ревью PR)" })
map("n", "<leader>rr", "<cmd>Atlas review<cr>", { desc = "Ревью пул-реквеста" })
map("n", "<leader>rp", "<cmd>Atlas pulls<cr>", { desc = "Пул-реквесты" })
map("n", "<leader>ri", "<cmd>Atlas issues<cr>", { desc = "Issues" })
map("n", "<leader>rs", "<cmd>Atlas search<cr>", { desc = "Поиск по PR и issues" })
map("n", "<leader>rc", "<cmd>Atlas create<cr>", { desc = "Создать PR или issue" })
map("n", "<leader>ro", "<cmd>Atlas open .<cr>", { desc = "Открыть репозиторий в браузере" })
map("n", "<leader>ra", "<cmd>Atlas<cr>", { desc = "Atlas: выбрать команду" })
