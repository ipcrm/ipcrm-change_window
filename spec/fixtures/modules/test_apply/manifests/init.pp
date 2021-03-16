include ::change_window::apply
#
# Class test_apply - creates two resources with one set noop and the other not
class test_apply {
  change_window::apply { 'my_test_set':
    change_window_set => [
          [ '-05:00', 'window', {'start' => 'Friday', 'end' => 'Monday'}, {'start' => '22:00', 'end' => '02:00' }, [1,2,3,4,5], [1,2,3,4,5,6,7,8,9,10,12]],
          [ '-05:00', 'window', {'start' => 'Wednesday', 'end' => 'Thursday'}, {'start' => '22:00', 'end' => '02:00' }, [1,2,3,4,5], [1,2,3,4,5,6,7,8,9,10,12]],
        ],
    class_list        => [{
      'test_notify_parameter' => {
        mesg => 'test_notify_parameter',
      }
    }],
  }
  include ::test_notify_simple
}
