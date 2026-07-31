vim.pack.add({ "https://github.com/goolord/alpha-nvim" })

local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⣶⣶⣶⣶⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣮⣻⡿⣿⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣯⣿⠋⣿⣽⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣾⡟⠁⢹⣷⢿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠋⠀⠀⣿⣷⣷⣆⠀⠀⢀⣀⣀⣠⣤⣄⣀⡀⠀⣀⣀⣀⡀⠀⠀⣀⣀⣀⣀⣀⣀⣀⣀⣤⣄⣤⣤⡄⠀⠀⣄⣀⣀⡄⣠⣤⣤⣤⣤⣤⣤⣄⢠⣤⣤⡄⠀⢀⣀⣠⣤⣤⣤⣤⣤⣀⡰⣤⣤⣤⣤⣤⣤⡖⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣶⣾⣿⣿⣿⣶⣶⣶⣿⡿⣿⣿⣄⠀⠀⠙⣿⣿⠉⠻⠯⣟⢦⡈⣿⣿⠁⠀⠀⣽⣿⢿⣿⣿⡟⠛⠛⢿⠀⠻⣿⣿⣧⡀⠀⠙⣿⣿⠏⠛⠛⣿⢿⠛⠛⠿⠆⣿⣿⠀⠀⢸⣿⡟⢹⣿⡟⠉⢱⣿⠇⢻⣿⡏⠀⠙⢿⡇⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠋⠉⣿⣯⣿⠏⠉⠉⠁⠉⢻⣿⣿⣷⡀⠀⠀⣿⣿⠀⠀⠈⢹⣻⣷⠘⣿⣧⠀⣼⣿⠏⢸⣿⣿⣧⣤⣤⡌⠀⠈⣿⣿⣿⣿⣧⡀⣿⣇⠀⠀⠀⣿⣿⠀⠀⠀⠀⣿⣿⠀⠀⢸⣿⡇⢸⣿⡇⢶⣿⠁⠀⢸⣿⣷⣴⣶⠄⠁⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣻⡿⠀⠀⠀⠀⠀⠈⣿⣿⣿⣧⡀⠀⣿⣿⠀⠀⠀⣸⣿⡿⠀⢹⣿⣾⣿⠃⠀⢸⣿⣿⡇⠀⠉⠀⠀⠀⣷⡗⠙⠻⣿⣿⣿⣿⠀⠀⠀⣿⢻⠀⠀⠀⠀⣿⣿⡀⠀⢹⣿⡇⢸⣿⠇⠈⢿⣯⡀⢸⣿⡇⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣷⣤⣿⣿⣧⣤⣴⣿⠟⠁⠀⠀⢿⡿⠁⠀⢀⣸⣿⣿⣧⣤⣤⣶⠇⣠⣿⠇⠀⠀⠈⠻⣿⠟⠀⠀⢠⣿⣿⡀⠀⠀⠀⠙⢿⣷⣶⢿⣿⢇⣺⣿⣇⠀⠈⢿⣷⣿⣿⣷⡤⢤⣴⠏⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠿⠟⠛⠛⠛⠛⠀⠀⢀⣠⣴⠂⠀⠀⠈⠉⠉⣉⣉⣉⣉⣉⣉⣀⣀⣀⣀⣀⣀⣉⣁⣀⣀⣀⠀⢀⣀⣀⣀⣀⣀⠀⣉⣀⣀⣀⣀⣀⠀⠁⠀⠀⠀⠋⠀⠀⠀⢀⣄⣀⣀⣠⣅⣀⠀⣀⣀⣉⣉⣉⡀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣷⣾⣿⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⢿⣿⣿⣿⡟⠀⠈⢿⣿⡿⢿⣿⣧⠀⠀⠀⠀⠀⠀⠀⢤⣿⣿⡿⣿⣿⡿⠋⠀⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡿⠛⠁⠀⠀⠰⣿⣿⠟⠛⠛⠚⠛⠛⣿⣿⣿⣿⠛⠛⠛⠻⠻⢿⣿⠀⢸⣿⣿⣿⡇⠀⠀⠈⣿⣿⣽⣿⣿⣧⠀⠀⠀⠀⠀⣰⣿⣿⣽⣿⣿⡏⠀⠀⠀⠀⢸⣿⣿⣿⣿⠉⠉⠉⠉⠉⠙⠻⢣⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⣠⣴⣶⣶⣄⠀⠀⠀⢀⣀⢀⣄⡀⣀⣴⣤⣿⣿⣿⣷⣶⣶⣶⣤⣤⣿⣴⣶⣶⣦⣤⣤⣤⣿⣿⣿⣧⣤⣤⣤⣤⣤⣤⣝⣤⣼⣿⣿⣿⣧⣤⣤⣴⣿⣿⣿⣿⣿⣿⣷⣠⣤⣤⣼⣿⣿⡿⢻⣿⣿⡇⣤⣤⣤⣤⣼⣟⣛⣛⣛⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀",
    "⠸⣿⣿⣿⣿⣿⣷⣿⣻⣿⢯⣿⣿⣽⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣞⣿⣿⣿⣯⢿⣻⣿⣿⡿⣽⢾⣿⣿⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⡄",
    "⠈⠻⣿⣿⣿⡿⠿⠿⠿⢿⠾⠿⢷⣿⣏⣿⣿⣿⣿⣿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⡇⡿⡿⠿⠿⠿⠿⠿⠿⠿⠿⢿⣿⡿⠿⠿⠿⠿⠿⣿⣿⣧⠿⠎⢿⣿⣿⣷⣿⢿⡿⠹⠿⢸⣿⣿⣿⠿⠿⠿⠿⢿⣿⣿⣿⣿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠟⠋⠁⠀",
    "⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⣿⣿⣿⣍⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡆⠀⠀⢰⣿⣿⣿⠀⠀⠈⢯⣳⣿⣯⣿⠃⠀⠀⢸⣿⢯⣽⠀⠀⠀⠀⢸⣿⣷⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣷⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡧⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣇⠀⢀⣾⣿⣿⣿⠀⠀⠀⠈⢻⣿⣾⠃⠀⠀⠀⣸⣿⣯⢿⡆⠀⠀⢀⣾⣿⣿⣿⣿⣶⣶⣶⣶⣶⣾⣶⣿⡟⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠿⣿⣟⠻⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⢿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⣾⠿⠟⠛⠛⠿⠀⠾⠽⠿⠿⠛⠂⠀⠀⠀⠀⠻⠋⠀⠀⠀⠀⠛⠛⠛⠛⠛⠂⠐⠿⠷⠯⠿⠷⢿⣿⣿⣿⣿⣿⡿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡾⠟⠋⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠳⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀",
}

dashboard.section.buttons.val = {
    dashboard.button("f", "" .. " Find File", function() Snacks.picker.files() end),
    dashboard.button("n", "" .. " New File", "enew"),
    dashboard.button("s", "" .. " Find session", function() require("resession").load() end),
    dashboard.button("p", "󰣷" .. " Find project", function() Snacks.picker.projects() end),
    dashboard.button("c", "" .. " Config", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end),
    dashboard.button("q", "󰠚" .. " Quit", "<Cmd>qa<CR>"),
}

-- Секция сессий: последние 9 сессий, свежие сверху, по цифрам 1-9
local MAX_SESSIONS = 9

local function get_session_buttons()
    local ok, sessions_mod = pcall(require, "plugins.resession")
    if not ok then
        return {}
    end
    local resession = require("resession")
    local sessions = sessions_mod.list(MAX_SESSIONS)
    if #sessions == 0 then
        return { { type = "text", val = "No sessions found 😥", opts = { position = "center" } } }
    end
    -- выравниваем даты в колонку по ширине самого длинного имени
    local width = 0
    for _, name in ipairs(sessions) do
        width = math.max(width, vim.fn.strdisplaywidth(sessions_mod.display_name(name)))
    end

    local btns = {}
    for i, name in ipairs(sessions) do
        local key = tostring(i)
        local label = sessions_mod.display_name(name)
        local pad = string.rep(" ", width - vim.fn.strdisplaywidth(label) + 2)
        table.insert(
            btns,
            dashboard.button(
                key,
                "󱇒 " .. label .. pad .. sessions_mod.timestamp(name),
                function() resession.load(name) end
            )
        )
    end
    return btns
end

local sessions_section = {
    type = "group",
    val = function()
        return {
            { type = "text", val = "Sessions", opts = { hl = "Special", position = "center" } },
            { type = "padding", val = 1 },
            { type = "group", val = get_session_buttons() },
        }
    end,
}

alpha.setup({
    layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 2 },
        sessions_section,
        { type = "padding", val = 2 },
        dashboard.section.footer,
    },
    opts = {},
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "alpha",
    callback = function() vim.opt_local.spell = false end,
})
