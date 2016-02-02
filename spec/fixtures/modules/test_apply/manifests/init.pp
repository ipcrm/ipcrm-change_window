include ::change_window::apply
#
# Class test_apply - creates two resources with one set noop and the other not
class test_apply {
  change_window::apply { 'my_test_set':
    change_window_set => 'false_change_window',
    class_list        => [{
      'notify' => {
        'notify_false_change_window' => {},
      }
    }],
  }
  include ::test_notify
}
