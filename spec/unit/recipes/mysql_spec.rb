require 'spec_helper'
require 'fauxhai'

describe 'ruby-support::mysql' do
  context 'On Centos 7.1 with defaults set' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.1.1503') do |node|
        Chef::Config[:client_key] = "/etc/chef/client.pem"
        node.set['ruby-deployment']['application']['name'] = 'test'
        stub_command("which sudo").and_return('/usr/bin/sudo')
        node.set['authorization']['sudo']['groups'] = ["admin", "wheel", "test"]
        node.set['ssh_keys'] = ''
        node.default['ssh_keys'] = { test: ["test"] }
      end.converge(described_recipe)
    end

    # included recipes
    recipe_list = ['ruby-support::default']

    recipe_list.each do |name|
      it 'includes the recipe ' + name do
        stub_data_bag_item("commerce-solutions", "single-copy-self-service").and_return('scss')
        expect(chef_run).to include_recipe(name)
      end
    end

    it 'creates a app directory' do
      expect(chef_run).to create_directory('/opt/rubyapp/test/')
    end

    it 'creates an app config directory' do
      expect(chef_run).to create_directory('/opt/rubyapp/test/config/')
    end

    it 'creates the database template' do
      expect(chef_run).to create_template('/opt/rubyapp/test/config/database.yml')
    end

    # installed packages
    package_list = ['epel-release', 'pygpgme', 'curl']

    package_list.each do |name|
      it 'installs ' + name do
        expect(chef_run).to install_package(name)
      end
    end

 end
end