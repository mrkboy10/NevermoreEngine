--!strict
--[=[
	Provide a variety of utility table operations
	@class Table
]=]

local Table = {}

export type Array<Value> = { [number]: Value }
export type Map<Key, Value> = { [Key]: Value }

--[=[
	Concats `target` with `source` in-place, modifying the target

	@param target table -- Table to append to
	@param source table -- Table read from
	@return table -- parameter table
]=]
function Table.append<T>(target: Array<T>, source: Array<T>): Array<T>
	for _, value in source do
		target[#target + 1] = value
	end

	return target
end

--[=[
	Shallow merges two tables without modifying either.

	@param orig table -- Original table
	@param new table -- Result
	@return table
]=]
function Table.merge(orig, new)
	local result = table.clone(orig)
	for key, val in new do
		result[key] = val
	end
	return result
end

--[=[
	Reverses the list and returns the reversed copy

	@param orig table -- Original table
	@return table
]=]
function Table.reverse<T>(orig: Array<T>): Array<T>
	local new = {}
	for i = #orig, 1, -1 do
		table.insert(new, orig[i])
	end
	return new
end

--[=[
	Returns a list of all of the values that a table has.

	@param source table -- Table source to extract values from
	@return table -- A list with all the values the table has
]=]
function Table.values<T>(source: Map<any, T>): Array<T>
	local new = {}
	for _, val in source do
		table.insert(new, val)
	end
	return new
end

--[=[
	Returns a list of all of the keys that a table has. (In order of pairs)

	@param source table -- Table source to extract keys from
	@return table -- A list with all the keys the table has
]=]
function Table.keys<T>(source: Map<T, any>): Array<T>
	local new = {}
	for key, _ in source do
		table.insert(new, key)
	end
	return new
end

--[=[
	Shallow merges two lists without modifying either.

	@param orig table -- Original table
	@param new table -- Result
	@return table
]=]
function Table.mergeLists<T, U>(orig: Array<T>, new: Array<U>): Array<T | U>
	local _table = {}
	for _, val in orig do
		table.insert(_table, val)
	end
	for _, val in new do
		table.insert(_table, val)
	end
	return _table
end

--[=[
	Swaps keys with values, overwriting additional values if duplicated.

	@param orig table -- Original table
	@return table
]=]
function Table.swapKeyValue(orig)
	local tab = {}
	for key, val in orig do
		tab[val] = key
	end
	return tab
end

--[=[
	Converts a table to a list.

	@param _table table -- Table to convert to a list
	@return table
]=]
function Table.toList<T>(_table: { [any]: T }): { T }
	local list = {}
	for _, item in _table do
		table.insert(list, item)
	end
	return list
end

--[=[
	Counts the number of items in `_table`.
	Useful since `__len` on table in Lua 5.2 returns just the array length.

	@param _table table -- Table to count
	@return number -- count
]=]
function Table.count(_table): number
	local count = 0
	for _, _ in _table do
		count = count + 1
	end
	return count
end

--[=[
	Shallow copies a table from target into a new table

	@function Table.copy
	@param target table -- Table to copy
	@return table -- Result
	@within Table
]=]
Table.copy = table.clone

--[=[
	Deep copies a table including metatables

	@param target table -- Table to deep copy
	@param _context table? -- Context to deepCopy the value in
	@return table -- Result
]=]
function Table.deepCopy(target: any, _context: any?)
	_context = _context or {}
	if _context[target] then
		return _context[target]
	end

	if type(target) == "table" then
		local new = {}
		_context[target] = new
		for index, value in target do
			new[Table.deepCopy(index, _context)] = Table.deepCopy(value, _context)
		end
		return setmetatable(new, Table.deepCopy(getmetatable(target), _context))
	else
		return target
	end
end

--[=[
	Overwrites a table's value
	@param target table -- Target table
	@param source table -- Table to read from
	@return table -- target
]=]
function Table.deepOverwrite(target, source)
	for index, value in source do
		if type(target[index]) == "table" and type(value) == "table" then
			target[index] = Table.deepOverwrite(target[index], value)
		else
			target[index] = value
		end
	end
	return target
end

--[=[
	Gets an index by value, returning `nil` if no index is found.
	@param haystack table -- To search in
	@param needle Value to search for
	@return The index of the value, if found
	@return nil -- if not found
]=]
function Table.getIndex<T>(haystack: { T }, needle: T): number?
	assert(needle ~= nil, "Needle cannot be nil")

	for index, item in haystack do
		if needle == item then
			return index
		end
	end

	return nil
end

--[=[
	Recursively prints the table. Does not handle recursive tables.

	@param _table table -- Table to stringify
	@param indent number? -- Indent level
	@param output string? -- Output string, used recursively
	@return string -- The table in string form
]=]
function Table.stringify<Key, Value>(_table: Map<Key, Value>, indent: number?, output: string?): string
	local result = output or tostring(_table)
	indent = indent or 0
	for key, value in _table do
		local formattedText = "\n" .. string.rep("  ", indent) .. tostring(key) .. ": "
		if type(value) == "table" then
			result = result .. formattedText
			result = Table.stringify(value, indent + 1, result)
		else
			result = result .. formattedText .. tostring(value)
		end
	end
	return result
end

--[=[
	Returns whether `value` is within `table`

	@param _table table -- To search in for value
	@param value any -- Value to search for
	@return boolean -- `true` if within, `false` otherwise
]=]
function Table.contains<T>(_table: { T }, value: T): boolean
	for _, item in _table do
		if item == value then
			return true
		end
	end

	return false
end

--[=[
	Overwrites an existing table with the source values.

	@param target table -- Table to overwite
	@param source table -- Source table to read from
	@return table -- target
]=]
function Table.overwrite(target, source)
	for index, item in source do
		target[index] = item
	end

	return target
end

--[=[
	Deep equivalent comparison of a table assuming keys are indexable in the same way.

	@param target table -- Table to check
	@param source table -- Other table to check
	@return boolean
]=]
function Table.deepEquivalent(target, source)
	if target == source then
		return true
	end

	if type(target) ~= type(source) then
		return false
	end

	if type(target) == "table" then
		for key, value in target do
			if not Table.deepEquivalent(value, source[key]) then
				return false
			end
		end

		for key, value in source do
			if not Table.deepEquivalent(value, target[key]) then
				return false
			end
		end

		return true
	else
		-- target == source should do it.
		return false
	end
end

--[=[
	Takes `count` entries from the table. If the table does not have
	that many entries, will return up to the number the table has to
	provide.

	@param source table -- Source table to retrieve values from
	@param count number -- Number of entries to take
	@return table -- List with the entries retrieved
]=]
function Table.take(source, count)
	local n = math.min(#source, count)
	local newTable = table.create(n)

	for i = 1, n do
		newTable[i] = source[i]
	end

	return newTable
end

local function errorOnIndex(_, index)
	error(string.format("Bad index %q", tostring(index)), 2)
end

local READ_ONLY_METATABLE = {
	__index = errorOnIndex,
	__newindex = errorOnIndex,
}

--[=[
	Sets a metatable on a table such that it errors when
	indexing a nil value

	@param target table -- Table to error on indexing
	@return table -- The same table, with the metatable set to readonly
]=]
function Table.readonly<T>(target: T): T
	return table.freeze(setmetatable(target, READ_ONLY_METATABLE))
end

--[=[
	Sets a metatable on a table such that it errors when
	indexing a nil value

	@param target table -- Table to error on indexing
	@return table -- The same table, with the target set to error on nil
]=]
function Table.errorOnNilIndex(target)
	return setmetatable(target, READ_ONLY_METATABLE)
end

--[=[
	Recursively sets the table as ReadOnly

	@param target table -- Table to error on indexing
	@return table -- The same table
]=]
function Table.deepReadonly(target)
	for _, item in target do
		if type(item) == "table" then
			Table.deepReadonly(item)
		end
	end

	return Table.readonly(target)
end

return Table
