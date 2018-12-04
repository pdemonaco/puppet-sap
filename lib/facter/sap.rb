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
          Dir.foreach('/usr/sap/' + sid) do |instdir|
            if %r!^(?<insttype>[A-Z]+)(?<instnum>[0-9]{2})$! =~ instdir
              inst_data = {}
              # Record the type
              inst_data[:type] = insttype.strip

              # Identify each profile file and add it to an array
              profile_files = []
              profile_dir = File.join('/sapmnt', sid, '/profile')
              profile_matches = Dir.glob(
                File.join(profile_dir, "*#{insttype.strip}#{instnum.strip}*"),
              )
              profile_matches.each do |profile_file|
                profile_files.push(profile_file.strip)
              end
              inst_data[:profiles] = profile_files

              # Complete the entry
              sid_instances[instnum.strip] = inst_data
            end
          end
          sid_detail[:instances] = sid_instances

          # Check for a database instance
          if Dir.exist?('/db2/' + sid)
            inst_data = {}
            inst_data[:type] = 'db2'
            sid_instances[:database] = inst_data
          end
          sid_hash[sid] = sid_detail
        end
      end
      { sid_hash: sid_hash }
    end
  end
end
