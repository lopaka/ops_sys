name        'sys'
description 'System scripts'

version     '1.0.20150619'

recipe      'sys::setup_hostname', 'Set hostname'
recipe      'sys::setup_collectd', 'Set collectd'

attribute   'HOSTNAME',
  :display_name => 'HOSTNAME',
  :description => 'The desired hostname of the instance. Reccomended value is ENV:RS_SERVER_NAME',
  :required => 'optional',
  :type => 'string',
  :default => 'env:RS_SERVER_NAME',
  :recipes => ['sys::setup_hostname']

# This is for collectd server
attribute   "COLLECTD_SERVER",
  :display_name => "RightScale monitoring server to send data to",
  :required => "optional",
  :type => "string",
  :default => "env:RS_TSS",
  :recipes => ["sys::setup_collectd"]

attribute   "RS_INSTANCE_UUID",
  :display_name => "RightScale monitoring ID for this server",
  :required => "optional",
  :type => "string",
  :default => "env:RS_INSTANCE_UUID",
  :recipes => ["sys::setup_collectd"]

