#
# Class: test_notify_paramter - creates a notify resource with optionally
#   specified title.
class test_notify_parameter(
  $mesg = 'test_notify_parameter',
) {

  notify { $mesg: }

}
