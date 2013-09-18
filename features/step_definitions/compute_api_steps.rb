# coding: utf-8


Given(/^I have an account which roled member of OpenStack$/) do
  @member_config = $os_config[:member]
  @keystone = Fog::Identity.new provider: 'OpenStack',
                openstack_auth_url: $os_config[:platform][:openstack_auth_url] + '/tokens',
                openstack_username: @member_config[:name],
                openstack_api_key:  @member_config[:api_key],
                connection_options: { ssl_verify_peer: false }
  roles = @keystone.current_user['roles']
  roles.select! {|a| a.has_value?('_member_')}
  expect(roles.size).to eql 1
  @credentials = @keystone.credentials
end

Given(/^I retrieve "(.*?)" from API$/) do |api|
  ## set instance such as @compute, @network, @image ...
  self.instance_variable_set "@#{api.downcase}",
    Fog.const_get(api).new(provider: 'OpenStack',
      openstack_auth_url: $os_config[:platform][:openstack_auth_url] + '/tokens',
      openstack_username: @member_config[:name],
      openstack_api_key:  @member_config[:api_key],
      openstack_tenant:   @member_config[:tenant],
      connection_options: { ssl_verify_peer: false }
    )
end

And(/^My current tenant is available$/) do
  current_tenant = @keystone.current_tenant
  expect(current_tenant['name']).to eql @member_config[:tenant]
  expect(current_tenant['enabled']).to be_true
end

Then(/^There is at least one ACTIVE router$/) do
  routers = @network.list_routers[:body]['routers']
  routers.select! {|x| x['status'] == 'ACTIVE'}
  expect(routers.size).to be > 0
end

Then(/^It has network "(.*?)"$/) do |name|
  networks = @network.list_networks[:body]['networks']
  expect(networks.select {|n| n['name'] == name }).not_to be_empty
end

Then(/^There are at least one image$/) do
  expect(@image.list_public_images[:body]['images'].size).to be > 0
end

Then(/^There are at least one flavor$/) do
  expect(@compute.list_flavors[:body]['flavors'].size).to be > 0
end

Then(/^There are at least one keypair$/) do
  expect(@compute.list_key_pairs[:body]['keypairs'] .size).to be > 0
end
