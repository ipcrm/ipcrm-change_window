#
# Class: test_notify_simple - creates a notify resource with optionally
#   specified title.
class test_notify_simple(
  $mesg = 'test_notify_simple',
) {

  notify { $mesg: }

}
