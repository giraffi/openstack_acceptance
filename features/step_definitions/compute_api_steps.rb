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
  @avail_networks = @network.list_networks[:body]['networks']
  expect(@avail_networks.select {|n| n['name'] == name }).not_to be_empty
end

Then(/^There are at least one image$/) do
  @avail_images = @image.list_public_images[:body]['images']
  expect(@avail_images.size).to be > 0
end

Then(/^There are at least one flavor$/) do
  @avail_flavors = @compute.list_flavors[:body]['flavors']
  expect(@avail_flavors.size).to be > 0
end

Then(/^There are at least one keypair$/) do
  @avail_keypairs = @compute.list_key_pairs[:body]['keypairs']
  expect(@avail_keypairs.size).to be > 0
end

Given(/^A requirement which must be satisfied before create computer$/) do
  @avail_networks = @network.list_networks[:body]['networks']
  @avail_images = @image.list_public_images[:body]['images']
  @avail_flavors = @compute.list_flavors[:body]['flavors']
  @avail_keypairs = @compute.list_key_pairs[:body]['keypairs']
  expect(@avail_images.size).to be > 0
  expect(@avail_flavors.size).to be > 0
  expect(@avail_keypairs.size).to be > 0
end

When(/^I try to create computer with private nic$/) do
  priv_nic = @avail_networks.select {|n| n['name'] == 'int_net'}
  req_params = {
    flavor_ref: @avail_flavors.first['id'],
    name: 'cucumber_test',
    image_ref: @avail_images.first['id'],
    key_name: @member_config[:ssh_key],
    nics: [{'net_id' => priv_nic.first['id']}],
    metadata: {'cucumber' => 'BDD'}
  }
  @server = @compute.servers.create(req_params)
  @server.reload
  expect(@server.state).to eql 'BUILD'
end

Then(/^new computer should be ACTIVE$/) do
  Timeout::timeout(10) {
    until @server.state == 'ACTIVE'
      sleep 1
      @server.reload
    end
  }
end

Then(/^I try to destroy new computer$/) do
  expect(@server.destroy).to be_true
end

When(/^I create floating_ip and associate to new computer$/) do
  ext_net = @avail_networks.select {|n| n['name'] == 'ext_net'}
  res = @network.create_floating_ip ext_net.first['id'] ,{:tenant_id => @keystone.current_tenant['id']}
  @fip = res[:body]['floatingip']
  res = @server.associate_address @fip['floating_ip_address']
  expect(res[:status]).to eql 202
end

When(/^I release floating_ip$/) do
  res = @network.delete_floating_ip @fip['id']
  expect(res[:status]).to eql 204
end

Then(/^computer has valid attributes$/) do
  @server.reload
  expect(@server.metadata.to_hash['cucumber']).to eql 'BDD'
end
