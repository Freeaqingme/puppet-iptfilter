class ipfilter::params {

    $config_file = '/etc/ipf/ipf.conf'

    $config_file_mode = $::operatingsystem ? {
      default => '0644',
    }

    $config_file_owner = $::operatingsystem ? {
      default => 'root',
    }

    $config_file_group = $::operatingsystem ? {
      default            => 'root',
    }

    # general settings
    $loopback_interface = 'lo0'
}
