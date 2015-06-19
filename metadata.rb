name        'ops_sys'
description 'System scripts'

version     '1.0.0'

recipe      'ops_sys::setup_hostname', 'Set hostname'

attribute   'HOSTNAME',
  :display_name => 'HOSTNAME',
  :description => 'The desired hostname of the instance. Reccomended value is ENV:RS_SERVER_NAME',
  :required => 'optional',
  :type => 'string',
  :default => 'env:RS_SERVER_NAME',
  :recipes => ['ops_sys::setup_hostname']
