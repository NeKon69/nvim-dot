return {
	{
		"ThePrimeagen/99",
		event = "VeryLazy",
		config = function()
			local _99 = require("99")
			local OpenCodeFileProvider = setmetatable({}, { __index = _99.Providers.BaseProvider })

			local function once(fn)
				local called = false
				return function(...)
					if called then
						return
					end
					called = true
					fn(...)
				end
			end

			local function maybe_extract_session_id(chunk)
				if type(chunk) ~= "string" then
					return nil
				end
				for line in chunk:gmatch("[^\r\n]+") do
					local ok, decoded = pcall(vim.json.decode, line)
					if ok and type(decoded) == "table" and type(decoded.sessionID) == "string" then
						return decoded.sessionID
					end
				end
				return nil
			end

			local function cleanup_session(session_id, logger)
				if not session_id or session_id == "" then
					return
				end
				vim.system({ "opencode", "session", "delete", session_id }, { text = true }, function(obj)
					if obj.code == 0 then
						return
					end
					vim.schedule(function()
						logger:warn(
							"failed to cleanup opencode session",
							"session_id",
							session_id,
							"stderr",
							vim.trim(obj.stderr or obj.stdout or "")
						)
					end)
				end)
			end

			function OpenCodeFileProvider._build_command(_, _, context)
				return {
					"opencode",
					"run",
					"--agent",
					"99-file-writer",
					"-m",
					context.model,
					"--format",
					"json",
					"-f",
					context.tmp_file .. "-prompt",
					"--",
					"Follow the attached prompt exactly. Write the final result to the TEMP_FILE path specified in it.",
				}
			end

			function OpenCodeFileProvider._get_provider_name()
				return "OpenCodeFileProvider"
			end

			function OpenCodeFileProvider._get_default_model()
				return "openai/gpt-5.4"
			end

			function OpenCodeFileProvider.fetch_models(callback)
				return _99.Providers.OpenCodeProvider.fetch_models(callback)
			end

			function OpenCodeFileProvider:make_request(query, context, observer)
				observer.on_start()

				local logger = context.logger:set_area(self:_get_provider_name())
				local session_id
				local once_complete = once(function(status, text)
					cleanup_session(session_id, logger)
					observer.on_complete(status, text)
				end)
				local command = self:_build_command(query, context)

				local proc = vim.system(
					command,
					{
						text = true,
						stdout = vim.schedule_wrap(function(err, data)
							if context:is_cancelled() then
								once_complete("cancelled", "")
								return
							end
							if err and err ~= "" then
								logger:debug("stdout#error", "err", err)
							end
							if data and not session_id then
								session_id = maybe_extract_session_id(data)
							end
						end),
						stderr = vim.schedule_wrap(function(err, data)
							if context:is_cancelled() then
								once_complete("cancelled", "")
								return
							end
							if err and err ~= "" then
								logger:debug("stderr#error", "err", err)
							end
							if data and not session_id then
								session_id = maybe_extract_session_id(data)
							end
							if not err and data and maybe_extract_session_id(data) == nil then
								observer.on_stderr(data)
							end
						end),
					},
					vim.schedule_wrap(function(obj)
						if context:is_cancelled() then
							once_complete("cancelled", "")
							return
						end
						if obj.code ~= 0 then
							local str = string.format("process exit code: %d\n%s", obj.code, vim.inspect(obj))
							once_complete("failed", str)
							logger:fatal(self:_get_provider_name() .. " make_query failed", "obj from results", obj)
							return
						end
						vim.schedule(function()
							local ok, res = self:_retrieve_response(context)
							if ok then
								once_complete("success", res)
							else
								once_complete("failed", "unable to retrieve response from temp file")
							end
						end)
					end)
				)

				context:_set_process(proc)
			end

			_99.setup({
				provider = OpenCodeFileProvider,
				model = "openai/gpt-5.4",
				completion = {
					source = "cmp",
					custom_rules = {},
				},
			})

			local prompts = _99.__get_state().prompts.prompts
			local base_output_file = prompts.output_file
			prompts.output_file = function()
				return base_output_file()
					.. "\nDo not use Markdown code fences in TEMP_FILE output."
					.. "\nOutput raw code only unless the user explicitly asks for fenced markdown."
			end

			vim.keymap.set("v", "<leader>av", function()
				_99.visual({})
			end, { desc = "99 Visual" })

			vim.keymap.set("n", "<leader>ax", function()
				_99.stop_all_requests()
			end, { desc = "99 Stop" })

			vim.keymap.set("n", "<leader>as", function()
				_99.search({})
			end, { desc = "99 Search" })

			vim.keymap.set("n", "<leader>ao", function()
				_99.open()
			end, { desc = "99 Open Result" })
		end,
	},
}
