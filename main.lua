-- ~/.config/yazi/plugins/hevi.yazi/main.lua
-- This plugin uses the `hevi` command to preview binary files.
--
-- Interface Description:
--  * peek(job): Asynchronous call, triggered when the user navigates between files using j or k.
--    Executes the preview based on job.file, job.skip, and job.area.
--  * seek(job): Synchronous call, triggered when the user scrolls using J or K.
--    Typically recalculates the number of lines to skip and calls peek to refresh the content.

local M = {}

-- Implementation of the peek method
function M:peek(job)
	-- Get the file path from job.file.url (assuming it's a complete file path as a string)
	local filepath = tostring(job.file.url)

	-- Call the `hevi` command to preview binary content
	-- Assume the `hevi` command takes the file path directly and outputs to stdout
	local child = Command("hevi"):arg("--color"):arg(filepath):stdout(Command.PIPED):stderr(Command.PIPED):spawn()
	if not child then
		ya.err("Failed to launch hevi: " .. filepath)
		return
	end

	local limit = job.area.h -- Preview area height, determines the number of lines to show
	local skip = job.skip -- Number of lines (or other units) to skip
	local i = 0
	local lines = {}

	-- Read output from `hevi`
	repeat
		local line, event = child:read_line()
		if event == 1 then
			ya.err("Error reading output from hevi")
			return require("code"):peek(job)
		elseif event ~= 0 then
			break
		end
		i = i + 1
		if i > skip then
			table.insert(lines, line:match("^(.-)\r?\n?$")) -- ✅ Remove trailing newline
		end
	until i >= skip + limit

	child:start_kill()

	-- Concatenate the output text
	local output = table.concat(lines, "\n")
	-- Replace tabs to ensure proper formatting; use tab size from preview config (default is 4)
	local tab_size = rt.preview.tab_size or 4
	output = output:gsub("\t", string.rep(" ", tab_size))

	-- Pass the processed text to Yazi for rendering the preview area
	ya.preview_widgets(job, {
		ui.Text.parse(output):area(job.area):wrap(rt.preview.wrap == "yes" and ui.Text.WRAP or ui.Text.WRAP_NO),
	})
end

-- Implementation of the seek method
-- This method handles user scrolling events synchronously, typically just re-calling peek to redraw
function M:seek(job)
	require("code"):seek(job)
end

return M
