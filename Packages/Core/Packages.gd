extends RefCounted
class_name Packages

# ==============================================================================
static var packages: Array[PackageData] = []
# ==============================================================================

static func initialize() -> void:
	const CORE_PACKAGE_DIR := "res://Packages"
	const USER_PACKAGE_DIR := "user://Packages"
	
	for package_dir in PackedStringArray([CORE_PACKAGE_DIR, USER_PACKAGE_DIR]):
		var dir := DirAccess.open(package_dir)
		if not dir:
			push_error("Could not open directory '%s': %s" % [package_dir, error_string(DirAccess.get_open_error())])
			return
		
		dir.include_hidden = true
		dir.include_navigational = false
		
		dir.list_dir_begin()
		
		while true:
			var file := dir.get_next()
			if file.is_empty():
				break
			
			var path := package_dir.path_join(file)
			if path == CORE_PACKAGE_DIR.path_join("Core"):
				continue
			
			load_package(path)


static func load_package(path: String) -> void:
	var package_data := PackageData.new()
	
	if path.get_extension().is_empty():
		# the package is a directory
		var script_path := path.path_join("script.gd")
		var source_code := FileAccess.get_file_as_string(script_path)
		if source_code.is_empty():
			push_error("There was an error when attempting to open '%s': %s" % [script_path, error_string(FileAccess.get_open_error())])
			return
		
		var script := GDScript.new()
		script.source_code = source_code
		script.reload()
		
		var singleton = script.new()
		
		if not singleton is Package:
			push_error("The script at '%s' does not extend class Package." % script_path)
			return
		
		package_data.singleton = singleton
		return
	
	# the package is a single script
	var source_code := FileAccess.get_file_as_string(path)
	if source_code.is_empty():
		push_error("There was an error when attempting to open '%s': %s" % [path, error_string(FileAccess.get_open_error())])
		return
	
	var script := GDScript.new()
	script.source_code = source_code
	script.reload()
	
	var singleton = script.new()
	
	if not singleton is Package:
		push_error("The script at '%s' does not extend class Package." % path)
		return
	
	package_data.singleton = singleton


static func call_method(method: StringName, args: Array = []) -> Array:
	var returns := []
	
	for package in packages:
		if not package.singleton.has_method(method):
			continue
		var r = package.singleton.callv(method, args)
		returns.append(r)
	
	return []

# ==============================================================================

class PackageData extends RefCounted:
	var singleton: Package
