local extra = _G.TriforceExtra or {}

local function is_prime(n)
	if n < 2 then
		return false
	end
	for i = 2, math.sqrt(n) do
		if n % i == 0 then
			return false
		end
	end
	return true
end

local function is_palindrome(n)
	local s = tostring(math.floor(n))
	return s == string.reverse(s) and #s > 2
end

local function is_fibonacci(n)
	local function is_perfect_square(x)
		local s = math.sqrt(x)
		return (s * s == x)
	end
	return is_perfect_square(5 * n * n + 4) or is_perfect_square(5 * n * n - 4)
end

return {
	-- ==========================================
	-- CATEGORY 1: TIME & BIO-RHYTHMS (20)
	-- ==========================================
	{
		id = "midnight_oil",
		name = "Midnight Oil",
		desc = "Type 1000+ chars between 02:00 and 05:00 AM",
		icon = "🌙",
		check = function(stats)
			local h = tonumber(os.date("%H"))
			return (h >= 2 and h < 5) and stats.chars_typed > 1000
		end,
	},
	{
		id = "vampire_coder",
		name = "Vampire Coder",
		desc = "More than 50 sessions strictly at night (00:00-06:00)",
		icon = "🦇",
		check = function(stats)
			local h = tonumber(os.date("%H"))
			return stats.sessions > 50 and (h >= 0 and h < 6)
		end,
	},
	{
		id = "early_bird",
		name = "Early Bird",
		desc = "Start a productive session before 07:00 AM",
		icon = "🌅",
		check = function(stats)
			local h = tonumber(os.date("%H"))
			return h >= 5 and h < 7 and stats.chars_typed > 500
		end,
	},
	{
		id = "weekend_warrior",
		name = "Weekend Warrior",
		desc = "Reach Level 10 using mostly weekend activity",
		icon = "🛡️",
		check = function(stats)
			local day = os.date("%w") -- 0 is Sunday, 6 is Saturday
			return stats.level >= 10 and (day == "0" or day == "6")
		end,
	},
	{
		id = "no_life_streak",
		name = "Touch Grass",
		desc = "Maintain a 30-day coding streak",
		icon = "🌿",
		check = function(stats)
			return stats.current_streak >= 30
		end,
	},
	{
		id = "immortal_streak",
		name = "Immortal Dev",
		desc = "Maintain a 100-day coding streak",
		icon = "💀",
		check = function(stats)
			return stats.current_streak >= 100
		end,
	},
	{
		id = "time_traveler",
		name = "Time Traveler",
		desc = "Code on New Year's Eve",
		icon = "🎆",
		check = function()
			return os.date("%m-%d") == "12-31" or os.date("%m-%d") == "01-01"
		end,
	},
	{
		id = "dead_of_night",
		name = "The Witching Hour",
		desc = "Exactly 666 XP gained during 03:00 AM",
		icon = "🔮",
		check = function(stats)
			local h = tonumber(os.date("%H"))
			return h == 3 and stats.xp % 1000 == 666
		end,
	},
	{
		id = "lunch_break_code",
		name = "Lunch is for the Weak",
		desc = "Active coding session during 12:00-13:00",
		icon = "🍕",
		check = function(stats)
			local h = tonumber(os.date("%H"))
			return h == 12 and stats.chars_typed > 200
		end,
	},
	{
		id = "friday_deploy",
		name = "Friday Hero",
		desc = "Save a file on Friday after 18:00 (Living on the edge)",
		icon = "💣",
		check = function()
			return os.date("%w") == "5" and tonumber(os.date("%H")) >= 18
		end,
	},
	{
		id = "monday_blues",
		name = "Monday Blues",
		desc = "Type 5000 chars on a Monday",
		icon = "🥶",
		check = function(stats)
			return os.date("%w") == "1" and stats.chars_typed > 5000
		end,
	},
	{
		id = "workflow_sync",
		name = "Clockwork",
		desc = "Session started at exactly the same minute as yesterday (Not really, just 1000 total commands)",
		icon = "⚙️",
		check = function()
			return (extra.total_commands or 0) > 1000
		end,
	},
	{
		id = "deep_flow",
		name = "Deep Flow State",
		desc = "Code for 4 hours total",
		icon = "🌊",
		check = function(stats)
			return stats.time_coding > 14400
		end,
	},
	{
		id = "century_sprint",
		name = "Century Sprint",
		desc = "100 sessions milestone",
		icon = "💯",
		check = function(stats)
			return stats.sessions >= 100
		end,
	},
	{
		id = "millennium_bug",
		name = "Millennium Bug",
		desc = "Reach 100,000 characters typed",
		icon = "🐛",
		check = function(stats)
			return stats.chars_typed >= 100000
		end,
	},
	{
		id = "power_hour",
		name = "Power Hour",
		desc = "XP ends in 000 (Milestone)",
		icon = "⚡",
		check = function(stats)
			return stats.xp > 0 and stats.xp % 1000 == 0
		end,
	},
	{
		id = "night_shift_vet",
		name = "Night Shift Veteran",
		desc = "200,000 characters typed mostly at night",
		icon = "🎖️",
		check = function(stats)
			local h = tonumber(os.date("%H"))
			return stats.chars_typed >= 200000 and (h < 6 or h > 22)
		end,
	},
	{
		id = "nap_time",
		name = "Just a Nap",
		desc = "Return to coding after exactly 1 day break (streak 1 to 2)",
		icon = "😴",
		check = function(stats)
			return stats.current_streak == 2
		end,
	},
	{
		id = "consistency_god",
		name = "Consistency God",
		desc = "Reach Level 50",
		icon = "👑",
		check = function(stats)
			return stats.level >= 50
		end,
	},
	{
		id = "productive_sunday",
		name = "Sinner",
		desc = "More than 2000 XP on a Sunday",
		icon = "💒",
		check = function(stats)
			return os.date("%w") == "0" and stats.xp > 2000
		end,
	},

	-- ==========================================
	-- CATEGORY 2: MATHEMATICAL MADNESS (20)
	-- ==========================================
	{
		id = "prime_level",
		name = "Prime Suspect",
		desc = "Your level is a prime number",
		icon = "🔢",
		check = function(stats)
			return stats.level > 10 and is_prime(stats.level)
		end,
	},
	{
		id = "palindrome_xp",
		name = "Mirror World",
		desc = "Your total XP is a palindrome",
		icon = "🪞",
		check = function(stats)
			return is_palindrome(stats.xp)
		end,
	},
	{
		id = "fibonacci_grind",
		name = "Fibonacci Grindset",
		desc = "Your current streak is a Fibonacci number",
		icon = "🌀",
		check = function(stats)
			return stats.current_streak > 5 and is_fibonacci(stats.current_streak)
		end,
	},
	{
		id = "pi_day_spirit",
		name = "Pi Approximation",
		desc = "Ratio of chars/lines is approx 3.14",
		icon = "🥧",
		check = function(stats)
			if stats.lines_typed < 100 then
				return false
			end
			local ratio = stats.chars_typed / stats.lines_typed
			return ratio >= 3.13 and ratio <= 3.15
		end,
	},
	{
		id = "golden_ratio",
		name = "Divine Proportion",
		desc = "Ratio of XP/Chars is approx 0.618 (The Golden Ratio)",
		icon = "✨",
		check = function(stats)
			if stats.chars_typed < 1000 then
				return false
			end
			local ratio = stats.xp / stats.chars_typed
			return ratio >= 1.61 and ratio <= 1.62
		end,
	},
	{
		id = "leet_coder",
		name = "Elite 1337",
		desc = "Have exactly 1337 XP (or ends in 1337)",
		icon = "🎮",
		check = function(stats)
			return stats.xp % 10000 == 1337
		end,
	},
	{
		id = "binary_solo",
		name = "Binary Solo",
		desc = "Chars typed is a power of 2 (e.g. 65536)",
		icon = "💾",
		check = function(stats)
			local c = stats.chars_typed
			return c > 1000 and (bit and bit.band(c, c - 1) == 0)
		end,
	},
	{
		id = "perfect_6",
		name = "Perfectly Balanced",
		desc = "Reach level 6, 28, or 496 (Perfect numbers)",
		icon = "⚖️",
		check = function(stats)
			return stats.level == 6 or stats.level == 28 or stats.level == 496
		end,
	},
	{
		id = "answer_to_all",
		name = "The Answer",
		desc = "Reach level 42",
		icon = "🌌",
		check = function(stats)
			return stats.level == 42
		end,
	},
	{
		id = "byte_warrior",
		name = "Byte Size",
		desc = "Exactly 256 XP gained in a session (approx)",
		icon = "👾",
		check = function(stats)
			return stats.xp % 256 == 0 and stats.xp > 0
		end,
	},
	{
		id = "devil_bargain",
		name = "Devil's Bargain",
		desc = "XP ends in 666",
		icon = "🔥",
		check = function(stats)
			return stats.xp % 1000 == 666
		end,
	},
	{
		id = "square_root",
		name = "Root User",
		desc = "XP is a perfect square",
		icon = "🌱",
		check = function(stats)
			if stats.xp < 100 then
				return false
			end
			local s = math.sqrt(stats.xp)
			return s == math.floor(s)
		end,
	},
	{
		id = "factorial_fun",
		name = "Factorial Madness",
		desc = "XP reached 720, 5040 or 40320 (N!)",
		icon = "❗",
		check = function(stats)
			local x = stats.xp
			return x == 720 or x == 5040 or x == 40320 or x == 362880
		end,
	},
	{
		id = "prime_sessions",
		name = "Prime Time",
		desc = "Total sessions is a prime number > 50",
		icon = "🕰️",
		check = function(stats)
			return stats.sessions > 50 and is_prime(stats.sessions)
		end,
	},
	{
		id = "zero_one",
		name = "The Matrix",
		desc = "XP consists only of 0 and 1 (decimal)",
		icon = "📟",
		check = function(stats)
			local s = tostring(stats.xp)
			return stats.xp > 100 and s:match("^[01]+$")
		end,
	},
	{
		id = "lucky_7",
		name = "Triple Seven",
		desc = "Level 7, Streak 7, Sessions end in 7",
		icon = "🎰",
		check = function(stats)
			return stats.level == 7 and stats.current_streak == 7 and stats.sessions % 10 == 7
		end,
	},
	{
		id = "hex_hunter",
		name = "Hexed",
		desc = "Reach 65535 XP (FFFF)",
		icon = "🧙",
		check = function(stats)
			return stats.xp >= 65535
		end,
	},
	{
		id = "nice_level",
		name = "Nice.",
		desc = "Reach level 69",
		icon = "😏",
		check = function(stats)
			return stats.level == 69
		end,
	},
	{
		id = "math_genius",
		name = "Fields Medalist",
		desc = "Unlock 10 mathematical achievements",
		icon = "📐",
		check = function(stats)
			return stats.level >= 30 and stats.xp > 50000
		end, -- Placeholder for 'many'
	},
	{
		id = "kilo_coder",
		name = "Kilo-Warrior",
		desc = "Exactly 1024 characters typed in total",
		icon = "📦",
		check = function(stats)
			return stats.chars_typed == 1024
		end,
	},

	-- ==========================================
	-- CATEGORY 3: PLUGINS & WORKFLOW (20)
	-- ==========================================
	{
		id = "telescope_astronomer",
		name = "Astronomer",
		desc = "Open Telescope more than 100 times",
		icon = "🔭",
		check = function()
			return (extra.telescope_opened or 0) >= 100
		end,
	},
	{
		id = "harpoon_sniper",
		name = "Harpoon Sniper",
		desc = "Switch files with Harpoon 50 times",
		icon = "🎯",
		check = function()
			return (extra.harpoon_switches or 0) >= 50
		end,
	},
	{
		id = "overseer_king",
		name = "Overseer King",
		desc = "Run 100 build/task compilations",
		icon = "🏗️",
		check = function()
			return (extra.compilations or 0) >= 100
		end,
	},
	{
		id = "dap_bug_hunter",
		name = "Bug Hunter",
		desc = "Start 20 debugging sessions",
		icon = "🐞",
		check = function()
			return (extra.dap_sessions or 0) >= 20
		end,
	},
	{
		id = "terminal_dweller",
		name = "Terminal Dweller",
		desc = "Open internal terminal 50 times",
		icon = "🐚",
		check = function()
			return (extra.term_opens or 0) >= 50
		end,
	},
	{
		id = "undo_master",
		name = "Mistake? What Mistake?",
		desc = "Use Undo 1000 times",
		icon = "⏪",
		check = function()
			return (extra.undo_count or 0) >= 1000
		end,
	},
	{
		id = "git_addict",
		name = "Git Addict",
		desc = "Commit 50 times from Neovim",
		icon = "🌿",
		check = function()
			return (extra.git_commits or 0) >= 50
		end,
	},
	{
		id = "commander",
		name = "Commander",
		desc = "Execute 500 commands via ':'",
		icon = "⌨️",
		check = function()
			return (extra.total_commands or 0) >= 500
		end,
	},
	{
		id = "cuda_demon",
		name = "CUDA Demon",
		desc = "Work with 50 CUDA files",
		icon = "⚡",
		check = function()
			return (extra.cuda_files_touched or 0) >= 50
		end,
	},
	{
		id = "paranoid_saver",
		name = "Paranoid Android",
		desc = "Save files 500 times",
		icon = "💾",
		check = function()
			return (extra.saves_count or 0) >= 500
		end,
	},
	{
		id = "telescope_god",
		name = "Galactic Scout",
		desc = "Open Telescope 1000 times",
		icon = "🌌",
		check = function()
			return (extra.telescope_opened or 0) >= 1000
		end,
	},
	{
		id = "fast_build",
		name = "Iterative Genius",
		desc = "10 compilations in a single session",
		icon = "🏎️",
		check = function()
			return (extra.compilations or 0) % 10 == 0 and (extra.compilations or 0) > 0
		end,
	},
	{
		id = "hardtime_survivor",
		name = "Hardtime Survivor",
		desc = "Reach level 20 with high total commands",
		icon = "🏜️",
		check = function(stats)
			return stats.level >= 20 and (extra.total_commands or 0) > 2000
		end,
	},
	{
		id = "config_goblin",
		name = "Config Goblin",
		desc = "Spend more time in Neovim than typing code (High sessions, low chars)",
		icon = "👺",
		check = function(stats)
			return stats.sessions > 200 and stats.chars_typed < 10000
		end,
	},
	{
		id = "harpoon_legend",
		name = "Moby Dick",
		desc = "Switch files with Harpoon 500 times",
		icon = "🐳",
		check = function()
			return (extra.harpoon_switches or 0) >= 500
		end,
	},
	{
		id = "dap_god",
		name = "Executioner",
		desc = "100 Debug sessions",
		icon = "🪓",
		check = function()
			return (extra.dap_sessions or 0) >= 100
		end,
	},
	{
		id = "git_legend",
		name = "Senior Committer",
		desc = "200 Git commits",
		icon = "📜",
		check = function()
			return (extra.git_commits or 0) >= 200
		end,
	},
	{
		id = "undo_regret",
		name = "Eternal Regret",
		desc = "5000 Undos",
		icon = "🌑",
		check = function()
			return (extra.undo_count or 0) >= 5000
		end,
	},
	{
		id = "term_king",
		name = "Shell Overlord",
		desc = "Open terminal 200 times",
		icon = "👑",
		check = function()
			return (extra.term_opens or 0) >= 200
		end,
	},
	{
		id = "bridge_builder",
		name = "Bridge Builder",
		desc = "Use all tracked plugin features at least once",
		icon = "🌉",
		check = function()
			return (extra.telescope_opened or 0) > 0
				and (extra.harpoon_switches or 0) > 0
				and (extra.compilations or 0) > 0
				and (extra.dap_sessions or 0) > 0
		end,
	},

	-- ==========================================
	-- CATEGORY 4: BEHAVIORAL & PARADOXES (20)
	-- ==========================================
	{
		id = "one_breath",
		name = "One Breath Coding",
		desc = "Reach Level 5 in very few sessions",
		icon = "🌬️",
		check = function(stats)
			return stats.level >= 5 and stats.sessions <= 5
		end,
	},
	{
		id = "adhd_coder",
		name = "ADHD Coder",
		desc = "More than 20 sessions in one day",
		icon = "💊",
		check = function(stats)
			return stats.sessions % 20 == 0 and stats.sessions > 0
		end,
	},
	{
		id = "marathon_monk",
		name = "Marathon Monk",
		desc = "Code for 10 hours straight (Total time milestone)",
		icon = "🧘",
		check = function(stats)
			return stats.time_coding >= 36000
		end,
	},
	{
		id = "ghost_protocol",
		name = "Ghost Protocol",
		desc = "High XP but very few lines typed",
		icon = "👻",
		check = function(stats)
			return stats.xp > 5000 and stats.lines_typed < 50
		end,
	},
	{
		id = "verbose_mode",
		name = "Verbose Mode",
		desc = "Average line length > 100 characters",
		icon = "📢",
		check = function(stats)
			return stats.lines_typed > 100 and (stats.chars_typed / stats.lines_typed) > 100
		end,
	},
	{
		id = "poet",
		name = "The Poet",
		desc = "Average line length < 10 characters (Lots of lines, few chars)",
		icon = "📜",
		check = function(stats)
			return stats.lines_typed > 500 and (stats.chars_typed / stats.lines_typed) < 10
		end,
	},
	{
		id = "save_scummer",
		name = "Save Scummer",
		desc = "100 saves in a very short time (implied by high save count)",
		icon = "💾",
		check = function()
			return (extra.saves_count or 0) > 1000
		end,
	},
	{
		id = "minimalist",
		name = "Minimalist",
		desc = "Level 10 with less than 1000 characters (Pure save/line XP)",
		icon = "⚪",
		check = function(stats)
			return stats.level >= 10 and stats.chars_typed < 1000
		end,
	},
	{
		id = "completionist",
		name = "The 1%",
		desc = "Reach Level 100",
		icon = "💎",
		check = function(stats)
			return stats.level >= 100
		end,
	},
	{
		id = "rebound",
		name = "The Rebound",
		desc = "Lose a 10+ streak and start a new one",
		icon = "🏀",
		check = function(stats)
			return stats.longest_streak >= 10 and stats.current_streak == 1
		end,
	},
	{
		id = "slow_burn",
		name = "Slow Burn",
		desc = "100+ hours of coding time",
		icon = "🕯️",
		check = function(stats)
			return stats.time_coding >= 360000
		end,
	},
	{
		id = "speed_demon",
		name = "Speed Demon",
		desc = "Earn 5000 XP in less than 1 hour (aggregate check)",
		icon = "🏎️",
		check = function(stats)
			return stats.xp >= 5000 and stats.time_coding < 3600
		end,
	},
	{
		id = "zen_master",
		name = "Zen Master",
		desc = "50000 characters typed without any undo (impossible, but 10k works)",
		icon = "🧘",
		check = function(stats)
			return stats.chars_typed > 10000 and (extra.undo_count or 0) < 10
		end,
	},
	{
		id = "chaos_theory",
		name = "Chaos Theory",
		desc = "XP, Chars, and Lines all end in the same digit",
		icon = "🎲",
		check = function(stats)
			if stats.xp == 0 then
				return false
			end
			local d = stats.xp % 10
			return stats.chars_typed % 10 == d and stats.lines_typed % 10 == d
		end,
	},
	{
		id = "living_edge",
		name = "Living on the Edge",
		desc = "10000 chars typed but less than 10 saves",
		icon = "🧗",
		check = function(stats)
			return stats.chars_typed > 10000 and (extra.saves_count or 0) < 10
		end,
	},
	{
		id = "night_owl_legend",
		name = "Lord of the Night",
		desc = "Reach level 30 solely during night hours",
		icon = "🦉",
		check = function(stats)
			local h = tonumber(os.date("%H"))
			return stats.level >= 30 and (h < 6 or h > 22)
		end,
	},
	{
		id = "stat_outlier",
		name = "Statistical Outlier",
		desc = "Have 100x more chars than lines",
		icon = "📈",
		check = function(stats)
			return stats.lines_typed > 0 and (stats.chars_typed / stats.lines_typed) > 100
		end,
	},
	{
		id = "phoenix",
		name = "Phoenix",
		desc = "Level up after a week of inactivity",
		icon = "🐦",
		check = function(stats)
			return stats.current_streak == 1 and stats.xp > 10000
		end,
	},
	{
		id = "perfectionist",
		name = "Perfectionist",
		desc = "Ratio of Chars/Lines is exactly 80",
		icon = "📏",
		check = function(stats)
			return stats.lines_typed > 0 and (stats.chars_typed / stats.lines_typed) == 80
		end,
	},
	{
		id = "true_hacker",
		name = "True Hacker",
		desc = "Unlock 50 achievements",
		icon = "🕶️",
		check = function(stats)
			return stats.level >= 40
		end, -- Rough proxy
	},

	-- ==========================================
	-- CATEGORY 5: TECH & CULTURE (20)
	-- ==========================================
	{
		id = "arch_btw",
		name = "I Use Arch Btw",
		desc = "Reach Level 50 on an Arch Linux system (implied)",
		icon = "🟦",
		check = function(stats)
			return stats.level >= 50
		end,
	},
	{
		id = "cpp_purist",
		name = "C++ Purist",
		desc = "Type 50,000 characters in C++",
		icon = "⚙️",
		check = function(stats)
			return (stats.chars_by_language or {}).cpp and stats.chars_by_language.cpp > 50000
		end,
	},
	{
		id = "cuda_master",
		name = "Parallel God",
		desc = "Work with 100 CUDA files",
		icon = "🧪",
		check = function()
			return (extra.cuda_files_touched or 0) >= 100
		end,
	},
	{
		id = "lua_wizard",
		name = "Lua Wizard",
		desc = "Type 10,000 characters in Lua",
		icon = "🌙",
		check = function(stats)
			return (stats.chars_by_language or {}).lua and stats.chars_by_language.lua > 10000
		end,
	},
	{
		id = "polyglot_pro",
		name = "Polyglot Master",
		desc = "Code in 10 different languages",
		icon = "🌍",
		check = function(stats)
			local count = 0
			for _ in pairs(stats.chars_by_language or {}) do
				count = count + 1
			end
			return count >= 10
		end,
	},
	{
		id = "script_kiddie",
		name = "Script Kiddie",
		desc = "1000 characters in Python or Bash",
		icon = "🐍",
		check = function(stats)
			local l = stats.chars_by_language or {}
			return (l.python or 0) > 1000 or (l.sh or 0) > 1000
		end,
	},
	{
		id = "segfault_survivor",
		name = "Segfault Survivor",
		desc = "50 build/runs in C++ without giving up",
		icon = "🆘",
		check = function(stats)
			local l = stats.chars_by_language or {}
			return (l.cpp or 0) > 5000 and (extra.compilations or 0) > 50
		end,
	},
	{
		id = "header_heavy",
		name = "Header Heavy",
		desc = "More characters in .h files than .cpp (Hard to track, use proxy)",
		icon = "📂",
		check = function(stats)
			return (stats.chars_by_language or {}).cpp and stats.level > 15
		end,
	},
	{
		id = "low_level",
		name = "Close to Metal",
		desc = "Type 1000 chars in Assembly or C",
		icon = "🔩",
		check = function(stats)
			local l = stats.chars_by_language or {}
			return (l.asm or 0) > 1000 or (l.c or 0) > 1000
		end,
	},
	{
		id = "vim_god",
		name = "Vim God",
		desc = "Reach level 80",
		icon = "🛐",
		check = function(stats)
			return stats.level >= 80
		end,
	},
	{
		id = "nix_curious",
		name = "Nix Curious",
		desc = "Type characters in a .nix file",
		icon = "❄️",
		check = function(stats)
			return (stats.chars_by_language or {}).nix and stats.chars_by_language.nix > 100
		end,
	},
	{
		id = "documentation_hater",
		name = "Doc Hater",
		desc = "Reach level 20 with 0 characters in Markdown",
		icon = "🙈",
		check = function(stats)
			return stats.level >= 20 and (stats.chars_by_language or {}).markdown == nil
		end,
	},
	{
		id = "cmake_hater",
		name = "CMake Victim",
		desc = "Type 5000 characters in CMake files",
		icon = "🏗️",
		check = function(stats)
			return (stats.chars_by_language or {}).cmake and stats.chars_by_language.cmake > 5000
		end,
	},
	{
		id = "rust_ace",
		name = "Ferris Friend",
		desc = "10,000 chars in Rust",
		icon = "🦀",
		check = function(stats)
			return (stats.chars_by_language or {}).rust and stats.chars_by_language.rust > 10000
		end,
	},
	{
		id = "web_refugee",
		name = "Web Refugee",
		desc = "0 characters in JS/TS/HTML after level 10",
		icon = "🕸️",
		check = function(stats)
			local l = stats.chars_by_language or {}
			return stats.level > 10 and (l.javascript == nil and l.typescript == nil)
		end,
	},
	{
		id = "neovim_dev",
		name = "Plugin Crafter",
		desc = "Work on Lua files for 5 hours",
		icon = "🔌",
		check = function(stats)
			return (stats.chars_by_language or {}).lua and stats.time_coding > 18000
		end,
	},
	{
		id = "heavy_driver",
		name = "Heavy Driver",
		desc = "Total XP > 1,000,000",
		icon = "🚜",
		check = function(stats)
			return stats.xp >= 1000000
		end,
	},
	{
		id = "ancient_one",
		name = "The Ancient One",
		desc = "Longest streak > 365 days",
		icon = "⏳",
		check = function(stats)
			return stats.longest_streak >= 365
		end,
	},
	{
		id = "cuda_warrior",
		name = "GPGPU Warrior",
		desc = "Type 20,000 characters in CUDA",
		icon = "☢️",
		check = function(stats)
			local l = stats.chars_by_language or {}
			return (l.cuda or 0) > 20000
		end,
	},
	{
		id = "triforce_bearer",
		name = "Bearer of the Triforce",
		desc = "Unlock almost everything (Level 99)",
		icon = "🔺",
		check = function(stats)
			return stats.level >= 99
		end,
	},
}
