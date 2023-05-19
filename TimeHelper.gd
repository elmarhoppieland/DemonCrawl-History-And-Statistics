extends Node

## Helper class for timestamps.
##
## Can handle a timestamp generated by DemonCrawl in the format [code]YYYY-MM-DD @ HH-MM-SS[/code].

# ==============================================================================

## Returns whether [code]timestamp_a[/code] is [b]before[/b] [code]timestamp_b[/code].
## Returns [code]false[/code] if the timestamps are equal.
## [br][br][b]Note:[/b] Would be equivalent to the [code]timestamp_a < timestamp_b[/code]
## if timestamps always had months and days of 2 digits.
func timestamp_is_before_timestamp(timestamp_a: String, timestamp_b: String) -> bool:
	return get_unix_time_from_timestamp(timestamp_a) < get_unix_time_from_timestamp(timestamp_b)


## Converts the given [code]timestamp[/code] to a Unix timestamp.
## [br][br][b]Note:[/b] Unix timestamps are often in UTC. This method does not do any
## timezone conversion, so the timestamp will be in the same timezone as the given datetime string.
## [br][br][b]Note:[/b] Any decimal fraction in the time string will be ignored silently.
func get_unix_time_from_timestamp(timestamp: String) -> int:
	var date := get_date(timestamp)
	var time := get_time(timestamp)
	
	return Time.get_unix_time_from_datetime_string(date + "T" + time)


## Converts the given [code]timestamp[/code] to a [Dictionary] of keys: [code]year[/code],
## [code]month[/code], [code]day[/code], [code]weekday[/code], [code]hour[/code],
## [code]minute[/code], and [code]second[/code].
## [br][br]If weekday is [code]false[/code], then the weekday entry is excluded
## (the calculation is relatively expensive).
## [br][br][b]Note:[/b] Any decimal fraction in the time string will be ignored silently.
func get_datetime_dict_from_timestamp(timestamp: String, weekday: bool = false) -> Dictionary:
	var date := get_date(timestamp)
	var time := get_time(timestamp)
	
	return Time.get_datetime_dict_from_datetime_string(date + "T" + time, weekday)


## Returns the number of seconds passed between [code]start_timestamp[/code] and [code]end_timestamp[/code].
func get_passed_seconds(start_timestamp: String, end_timestamp: String) -> int:
	return get_unix_time_from_timestamp(end_timestamp) - get_unix_time_from_timestamp(start_timestamp)


## Returns the date section of the given [code]timestamp[/code].
func get_date(timestamp: String) -> String:
	return timestamp.get_slice(" @", 0).trim_prefix("[")


## Returns the time section of the given [code]timestamp[/code].
func get_time(timestamp: String) -> String:
	return timestamp.get_slice("@ ", 1).trim_suffix("]")
