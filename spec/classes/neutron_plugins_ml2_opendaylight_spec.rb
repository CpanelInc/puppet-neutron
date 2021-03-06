require 'spec_helper'

describe 'neutron::plugins::ml2::opendaylight' do

  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron':
      core_plugin     => 'ml2' }"
  end

  let :default_params do
    {
      :package_ensure          => 'present',
      :odl_url                 => '<SERVICE DEFAULT>',
      :ovsdb_connection        => 'tcp:127.0.0.1:6639',
      :port_binding_controller => '<SERVICE DEFAULT>',
      :odl_hostconf_uri        => '<SERVICE DEFAULT>',
      :odl_features            => '<SERVICE DEFAULT>',
    }
  end

  let :params do
    {
      :odl_username           => 'user',
      :odl_password           => 'password',
    }
  end

  let :test_facts do
    {
      :operatingsystem        => 'default',
      :operatingsystemrelease => 'default',
    }
  end


  shared_examples_for 'neutron plugin opendaylight ml2' do
    before do
      params.merge!(default_params)
    end

    it 'should have' do
      is_expected.to contain_package('python-networking-odl').with(
        :ensure => params[:package_ensure],
        :tag    => 'openstack'
        )
    end

    it 'configures ml2_odl settings' do
      is_expected.to contain_neutron_plugin_ml2('ml2_odl/password').with_value(params[:odl_password]).with_secret(true)
      is_expected.to contain_neutron_plugin_ml2('ml2_odl/username').with_value(params[:odl_username])
      is_expected.to contain_neutron_plugin_ml2('ml2_odl/url').with_value(params[:odl_url])
      is_expected.to contain_neutron_plugin_ml2('ml2_odl/port_binding_controller').with_value(params[:port_binding_controller])
      is_expected.to contain_neutron_plugin_ml2('ml2_odl/odl_hostconf_uri').with_value(params[:odl_hostconf_uri])
      is_expected.to contain_neutron_plugin_ml2('ml2_odl/odl_features').with_value(params[:odl_features])
    end

    it 'configures neutron server settings' do
      is_expected.to contain_neutron_config('OVS/ovsdb_connection').with_value(params[:ovsdb_connection])
    end
  end


  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
          :osfamily               => 'RedHat',
          :operatingsystemrelease => '7'
      }))
    end

    it_configures 'neutron plugin opendaylight ml2'
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
          :osfamily               => 'Debian',
      }))
    end

    it_configures 'neutron plugin opendaylight ml2'
  end
end
