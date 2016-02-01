define change_window::apply(
  $change_window_set,
  $class_list,
) {
  validate_string($change_window_set)
  validate_array($class_list)

  # Default action is noop()
  # $change_windows = hiera($change_window_set,undef)
  $change_windows = hiera($change_window_set)
  if merge_change_windows($change_windows) == 'false' {
    notify{ "#{$title} not in change_windows #{$change_window_set}, setting noop() mode.": }
    noop()
  } else {
    notify{ "#{$title} in change_windows #{$change_window_set}": }
  }

  notify { "#{$class_list}":}
  $class_list.each |$class_entry| {
    if is_hash($class_entry) {
      $class_entry.each |$class_type, $class_definition| {
        create_resources($class_type, $class_definition)
      }
    } else {
      include $class_entry
    }


  }
}
