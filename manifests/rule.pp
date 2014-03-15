define ipfilter::rule (
    $action            = 'pass',
    $direction         = 'in',
    $in_interface      = '',
    $out_interface     = '', # unimplemented
    $source            = '',
    $source_v6         = '',
    $source_table      = '',
    $destination       = '',
    $destination_v6    = '',
    $protocol,
    $port,
    $state             = 'keep',
    $order             = $ipfilter::default_order,
    $log               = '', # unimplemented
    $enable            = '', # unimplemented
) {
    include ::ipfilter

    # The concat module may not support natural sorting,
    # so we make sure it's all at least 4 digits
    $true_order = $order ? {
      ''      => inline_template("<%= scope.lookupvar('ipfilter::default_order').to_s.rjust(4, '0') %>"),
      default => inline_template("<%= @order.to_s.rjust(4, '0') %>")
    }

    $content = ipfilter_format_rule($name, $action, $direction, $in_interface, $source, $source_v6, $destination, $destination_v6, $protocol, $port, $state)

    concat::fragment { "${module_name}-rule-${name}":
        target  => $ipfilter::config_file,
        order   => $true_order,
        content => "${content}\n\n",
        notify  => Service['ipfilter'],
    }
}
