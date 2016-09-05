require 'resolv'

module Puppet::Parser::Functions
    newfunction(:get_ip_addr, :type => :rvalue) do |args|
        hostname = args[0];
        ip = Resolv.getaddress hostname
        return ip
    end
end