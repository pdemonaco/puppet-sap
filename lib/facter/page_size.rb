Facter.add('page_size') do
  confine kernel: 'Linux'

  setcode do
    Facter::Core::Execution.exec('getconf PAGE_SIZE')
  end
end
