# frozen_string_literal: true

require 'spec_helper'

describe 'numad' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end

  context 'without parameters' do
    let(:facts) do
      {
        'path' => '/bin:/usr/bin',
      }
    end

    it { is_expected.to compile.with_all_deps }
    it {
      is_expected.to contain_package('numad')
        .with_ensure('installed')
        .that_notifies('Service[numad.service]')
    }

    it {
      is_expected.to contain_service('numad.service')
        .with_ensure(true)
        .with_enable(true)
      is_expected.not_to contain_file('/etc/systemd/system/numad.service.d/puppet.conf')
    }
  end

  context 'when given values for arguments' do
    let(:facts) do
      {
        'path' => '/bin:/usr/bin',
      }
    end
    let(:params) do
      {
        'numad_arguments' => [ '-i 15', '-C 1']
      }
    end
    it {
      is_expected.to contain_file('/etc/systemd/system/numad.service.d/puppet.conf')
        .with_ensure('file')
        .with_owner('root')
        .with_group('root')
        .with_mode('0444')
        .that_notifies('Service[numad.service]')
        .with_content(%r{\[Service\]})
        .with_content(%r{ExecStart=$})
        .with_content(%r{ExecStart=\/usr\/bin\/numad -i 15 -C 1})
    }
   end

end
