### sap.rb
#
# Custom fact to determin local SAP settings
#
# Author: Thomas Bendler <project@bendler-net.de>
# Date:   Fri Nov 11 11:47:53 CET 2016
#

Facter.add(:sap, type: :aggregate) do
  confine kernel: 'Linux'

  # Potential SID list
  sid_hash = {}

  # Identify all local SIDs by interrogating /sapmnt
  if File.exist? '/sapmnt'
    chunk(:sids) do
      Dir.foreach('/sapmnt') do |item|
        if item =~ %r{[A-Z0-9]{3}}
          sid = item.strip
          sid_detail = {}

          # Determine instance type
          if Dir.exist?('/usr/sap/' + sid + '/D*')
            sid_detail[:type] = 'abap'
          end
          if Dir.exist?('/usr/sap/' + sid + '/D*/j2ee')
            sid_detail[:type] = 'dual'
          end
          if Dir.exist?('/usr/sap/' + sid + '/J*')
            sid_detail[:type] = 'java'
          end

          # Determine instance components
          sid_instances = {}
          if Dir.exist?('/usr/sap/' + sid)
            Dir.foreach('/usr/sap/' + sid) do |instdir|
              if %r!^(?<insttype>[A-Z]+)(?<instnum>[0-9]{2})$! =~ instdir
                sid_instances[instnum] = insttype
              end
            end
          end

          # Check for a database instance
          if Dir.exist?('/db2/' + sid)
            sid_instances['database'] = 'db2'
          end
          # Remove duplicate instances and add
          if sid_instances.length > 0
            sid_detail[:instances] = sid_instances
          end
          sid_hash[sid] = sid_detail
        end
      end
      { sid_hash: sid_hash }
    end
  end
end
