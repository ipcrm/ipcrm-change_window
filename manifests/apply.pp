# Define: change_window::apply - given the name of a change_window_set,
#    set noop() for list of classes
##
# where:
#   $change_window_set = hiera key to window definitions
#   $class_list        = Array of classes to place under control
#
#   $class_list[] may take one of two forms, a string with a class name to
#    include or a hash suitable for create_resources().
#       simple : simple_class
#       complex: {'parameter_class' => {parm1 => 'xxx', parm2 => 'yyy'}}
##
define change_window::apply(
  $change_window_set,
  $class_list,
) {
  # Validate arguments
  validate_array($change_window_set)
  validate_array($class_list)

  # Lookup named schedule
  debug("change_window_set = ${change_window_set}")

  # Set noop() when not "whithin" the change_window
  if merge_change_windows($change_window_set) == 'false' {
    debug('not in change_window')
    notify{ "#{${title}} not in change_windows #{${change_window_set}}, setting noop() mode.": }
    noop()
  } else {
    debug('in change_window')
    notify{ "#{${title}} in change_windows #{${change_window_set}}": }
  }

  # Iterate the array of classes
  debug("class_list = ${class_list}")
  $class_list.each |$class_entry| {
    # complex class utilizing a hash structure
    if is_hash($class_entry) {
      create_resources('class', $class_entry)

    # Simple named class
    } else {
      include $class_entry
    }
  }
}
