#
# Class: test_notify - creates a notify resource with optionally
#   specified title.
class test_notify(
  $my_title = 'test_notify'
) {

  notify { $my_title: }

}
