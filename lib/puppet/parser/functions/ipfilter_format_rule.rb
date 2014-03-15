
module Puppet::Parser::Functions
  newfunction(:ipfilter_format_rule, :type => :rvalue, :doc => <<-EOS
Format IPFilter rule based on various inputs
    EOS
  ) do |args|
    name, action, direction, interface, source, source_v6, destination, destination_v6, protocol, port, state = args

    # action
    raise(ArgumentError, "action should be either pass or block") unless ['pass', 'block'].include?(action)
    log = (action == 'block') ? 'log' : ''

    # direction
    raise(ArgumentError, "direction should be either in or out") unless ['in', 'out'].include?(direction)

    # interface
    interface = "on #{interface}" unless interface.length == 0

    # source
    sources = []
    if source.kind_of?(Array)
        sources.concat(source)
    elsif source.length > 0
        sources << source
    end
    if source_v6.kind_of?(Array)
        sources.concat(source_v6)
    elsif source_v6.length > 0
        sources << source_v6
    end

    # destination
    destinations = []
    if destination.kind_of?(Array)
        destinations.concat(destination)
    elsif destination.length > 0
        destinations << destination
    end
    if destination_v6.kind_of?(Array)
        destinations.concat(destination_v6)
    elsif destination_v6.length > 0
        destinations << destination
    end

    raise(ArgumentError, "can not format rules for multiple sources and destinations at the same time (#{name}, #{sources}, #{destinations})") unless sources.length < 2 or destinations.length < 2
    # if source is empty, add 'any'
    sources << 'any' unless sources.length > 0
    # sanitize sources
    sources_copy = sources
    sources_copy.delete('0.0.0.0/0')
    sources_copy.delete('::')
    sources = ['any'] unless sources_copy.length > 0

    # same goes for destination
    destinations << 'any' unless destinations.length > 0
    # sanitize destinations
    destinations_copy = destinations
    destinations_copy.delete('0.0.0.0/0')
    destinations_copy.delete('::')
    destinations = ['any'] unless destinations_copy.length > 0

    # protocol
    protocol = "proto #{protocol}" unless protocol.length == 0

    # port
    raise(ArgumentError, "port should be numeric, not #{port}") unless port.to_s.scan(/^\d+$/)

    # state
    # TODO: implement this

    # expand multiple sources/destinations to multiple rules
    content = []
    sources.sort.each {|src|
       destinations.sort.each {|dst|
            content << "#{action} #{direction} #{log} quick #{interface} #{protocol} from #{src} to #{dst} port = #{port} keep state"
       }
    }

    raise(StandardError, "could not format rule based on parameters") unless content.length > 0

    # add rule name to ruleset
    content.unshift("# #{name}")

    return content.join("\n")
  end
end
