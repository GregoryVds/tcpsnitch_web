module LoopbackDetector
  def self.loopback?(ip)
    a = Addrinfo.ip(ip)
    a = a.ipv6_to_ipv4 if a.ipv6_v4mapped?
    a.ipv4_loopback? or a.ipv6_loopback?
  end
end
