### sap.rb
#
# Custom fact to determin local SAP settings
#
# Author: Thomas Bendler <project@bendler-net.de>
# Date:   Fri Nov 11 11:47:53 CET 2016
#

# Create a hash for SAP items
sap_items = Hash.new ''

# Detect SAP SID by analyzing /sapmnt
if File.exist?('/sapmnt')
  Dir.foreach('/sapmnt') do |item|
    sap_items['sid'] = item.match(%r{[A-Z0-9]{3}})
  end
end

# Detect type by analyzing /usr/sap/SID/INSTANCE
if Dir.exist?('/usr/sap/' + sap_items['sid'] + '/D*')
  sap_items['type'] = 'abap'
end
if Dir.exist?('/usr/sap/' + sap_items['sid'] + '/D*/j2ee')
  sap_items['type'] = 'dual'
end
if Dir.exist?('/usr/sap/' + sap_items['sid'] + '/J*')
  sap_items['type'] = 'java'
end

# Detect instance by analyzing /usr/sap/SID/INSTANCE
if Dir.exist?('/usr/sap/' + sap_items['sid'] + '/D*')
  sap_items['instance'] = 'dialog'
end
if Dir.exist?('/usr/sap/' + sap_items['sid'] + '/DV*')
  sap_items['instance'] = 'central'
end
if Dir.exist?('/usr/sap/' + sap_items['sid'] + '/J*')
  sap_items['instance'] = 'dialog'
end
if Dir.exist?('/usr/sap/' + sap_items['sid'] + '/SCS*')
  sap_items['instance'] = 'central'
end

# Set facts based on sap_keyname
unless sap_items.nil?
  sap_items.each do |key, val|
    unless val.nil?
      Facter.add("sap_#{key}") { setcode { val } }
    end
  end
end
