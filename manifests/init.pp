class ipfilter (
  $header_template    = "${module_name}/ipf.conf-header.erb",
  #$block_policy       = 'drop',
  #$scrub_traffic      = true,
  #$block_to_broadcast = true,
  #$block_urpf_failed  = true,
  $skip_loopback      = true,
  #$scrub_traffic      = true,
  #$enable_logging     = true,
  #$timeouts           = {},
  #$limits             = {},
) inherits ipfilter::params {

  $default_order = 5000

  concat { 'ipf.conf':
    ensure => present,
    name   => $ipfilter::config_file,
    owner  => $ipfilter::config_file_owner,
    group  => $ipfilter::config_file_group,
    mode   => $ipfilter::config_file_mode,
    notify  => Service['ipfilter'],
  }

  concat::fragment { 'ipf.conf-header':
    ensure  => present,
    target  => $ipfilter::config_file,
    content => template($header_template),
  }

  #svccfg -s ipfilter:default setprop firewall_config_default/policy = astring: "custom"
  #svccfg -s ipfilter:default setprop firewall_config_default/custom_policy_file = astring: "/etc/ipf/ipf.conf"
  exec { 'set-ipfilter-policy':
    user    => 'root',
    path    => [ '/usr/gnu/bin/', '/usr/sbin' ],
    command => 'svccfg -s ipfilter:default setprop firewall_config_default/policy = astring: "custom"',
    unless  => 'svccfg -s ipfilter:default listprop firewall_config_default/policy | awk \'{print $NF}\' | grep -w custom',
    notify  => Service['ipfilter'],
  }

  exec { 'set-ipfilter-policy-file':
    user    => 'root',
    path    => [ '/usr/gnu/bin/', '/usr/sbin' ],
    command => 'svccfg -s ipfilter:default setprop firewall_config_default/custom_policy_file = astring: "/etc/ipf/ipf.conf"',
    unless  => 'svccfg -s ipfilter:default listprop firewall_config_default/custom_policy_file | awk \'{print $NF}\' | grep -w /etc/ipf/ipf.conf',
    notify  => Service['ipfilter'],
  }

  # enable pf
  service { 'ipfilter':
    ensure  => running,
    enable  => true,
    name    => $ipfilter::service_name,
  }
}
