local M = {}

local function get_project_root()
	local root_markers = { ".git", "CMakeLists.txt", "Makefile" }
	local current = vim.fn.getcwd()

	for _, marker in ipairs(root_markers) do
		local marker_path = vim.fn.finddir(marker, current .. ";")
		if marker_path ~= "" then
			return vim.fn.fnamemodify(marker_path, ":h")
		end
	end

	return current
end

local function path_to_namespace(path)
	local namespace = path:gsub("/", "::")
	namespace = namespace:gsub("^::", "")
	namespace = namespace:gsub("::$", "")
	return namespace
end

local function to_upper_snake(str)
	return str:gsub("([A-Z])", "_%1"):gsub("^_", ""):upper()
end

local function ensure_dir(path)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
end

local templates = {
	{
		name = "C++ Class (Header + Source)",
		ext = { ".h", ".cpp" },
		generator = function(name, path)
			local header_guard = to_upper_snake(path:gsub("/", "_") .. "_" .. name) .. "_H"
			local namespace = path_to_namespace(path)
			local include_path = path ~= "" and path .. "/" .. name or name

			local header = string.format(
				[[#pragma once

namespace %s {

class %s {
public:
    %s();
    ~%s();
    
private:
    
};

} // namespace %s
]],
				namespace,
				name,
				name,
				name,
				namespace
			)

			local source = string.format(
				[[#include "%s.h"

namespace %s {

%s::%s() {
    
}

%s::~%s() {
}

} // namespace %s
]],
				include_path,
				namespace,
				name,
				name,
				name,
				name,
				namespace
			)

			return { header, source }
		end,
	},

	{
		name = "C++ Header-Only Class",
		ext = { ".h" },
		generator = function(name, path)
			local header_guard = to_upper_snake(path:gsub("/", "_") .. "_" .. name) .. "_H"
			local namespace = path_to_namespace(path)

			local header = string.format(
				[[#pragma once

namespace %s {

template<typename T>
class %s {
public:
    %s() {}
    ~%s() {}
    
private:
    
};

} // namespace %s
]],
				namespace,
				name,
				name,
				name,
				namespace
			)

			return { header }
		end,
	},

	{
		name = "CUDA Kernel (Header + Source)",
		ext = { ".h", ".cu" },
		generator = function(name, path)
			local namespace = path_to_namespace(path)
			local include_path = path ~= "" and path .. "/" .. name or name

			local header = string.format(
				[[#pragma once

#include <cuda_runtime.h>

namespace %s {

void %s_launch(float* d_output, const float* d_input, int size);

} // namespace %s
]],
				namespace,
				name,
				namespace
			)

			local source = string.format(
				[[#include "%s.h"

namespace %s {

__global__ void %s_kernel(float* output, const float* input, int size) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < size) {
        output[idx] = input[idx];
    }
}

void %s_launch(float* d_output, const float* d_input, int size) {
    int threads = 256;
    int blocks = (size + threads - 1) / threads;
    %s_kernel<<<blocks, threads>>>(d_output, d_input, size);
    cudaDeviceSynchronize();
}

} // namespace %s
]],
				include_path,
				namespace,
				name,
				name,
				name,
				namespace
			)

			return { header, source }
		end,
	},

	{
		name = "Single Header (.h)",
		ext = { ".h" },
		generator = function(name, path)
			local namespace = path_to_namespace(path)

			local header = string.format(
				[[#pragma once

namespace %s {

// TODO: Add declarations

} // namespace %s
]],
				namespace,
				namespace
			)

			return { header }
		end,
	},

	{
		name = "Single Source (.cpp)",
		ext = { ".cpp" },
		generator = function(name, path)
			local namespace = path_to_namespace(path)

			local source = string.format(
				[[namespace %s {

// TODO: Add implementation

} // namespace %s
]],
				namespace,
				namespace
			)

			return { source }
		end,
	},

	{
		name = "Python Module (.py)",
		ext = { ".py" },
		generator = function(name, path)
			local module = string.format(
				[["""
Module: %s
"""


def main():
    pass


if __name__ == "__main__":
    main()
]],
				name
			)

			return { module }
		end,
	},

	{
		name = "Rust Module (.rs)",
		ext = { ".rs" },
		generator = function(name, path)
			local module = string.format(
				[[pub struct %s {
}

impl %s {
    pub fn new() -> Self {
        Self {}
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_%s() {
        let obj = %s::new();
    }
}
]],
				name,
				name,
				name:lower(),
				name
			)

			return { module }
		end,
	},
}

function M.create_from_template()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Select Template",
			finder = finders.new_table({
				results = templates,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.name,
						ordinal = entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local template = selection.value

					vim.ui.input({
						prompt = "Enter path/filename (relative to project root): ",
						default = "",
					}, function(input)
						if not input or input == "" then
							return
						end

						local root = get_project_root()
						local last_slash = input:match("^.*()/")
						local path = last_slash and input:sub(1, last_slash - 1) or ""
						local name = last_slash and input:sub(last_slash + 1) or input

						local contents = template.generator(name, path)
						local created_files = {}

						for i, ext in ipairs(template.ext) do
							local dir_prefix = ext == ".h" and "include" or "src"
							local full_path = root .. "/" .. dir_prefix

							if path ~= "" then
								full_path = full_path .. "/" .. path
							end

							full_path = full_path .. "/" .. name .. ext

							ensure_dir(full_path)

							local file = io.open(full_path, "w")
							if file then
								file:write(contents[i])
								file:close()
								table.insert(created_files, full_path)
							end
						end

						if #created_files > 0 then
							vim.cmd("edit " .. created_files[1])
							vim.notify("Created: " .. table.concat(created_files, ", "), vim.log.levels.INFO)
						end
					end)
				end)
				return true
			end,
		})
		:find()
end

return M
