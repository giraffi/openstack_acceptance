# openstack acceptance test with cucumber

When we build new openstack privete cloud, should be run an acceptance test.


## Setup

Install dependencies.

```
bundle
```

### OpenStack Requiements

- Your Keystone should have a member which associate to tenant 'service(default tenant)'.
- A Member should have public key.
- Should import Image for nova.

## Configure

Put your credentials to `./.os_accept.yml`

```
---                                                                                                                                                                                                                                              
:platform:
  :openstack_auth_url: http://192.0.2.1.:5000/v2.0
:admin:
  :name: admin
  :api_key: admin_password
:member:
  :name: member_name
  :api_key: member_password
  :tenant: service
  :ssh_key: ssh_key_name
```

### config builder `bin/os_accept `


```
Commands:
  os_accept help [COMMAND]  # Describe available commands or one specific command
  os_accept init            # initialize: create configfile with ask
```

### `os_accept init`

Creates `.os_accept.yml` step by step. 

```
$ ./bin/os_accept init
Input openstack_auth_url
?  http://192.0.2.1.:5000/v2.0

Input openstack_admin username
? admin

Input openstack_admin_api_key(password)
? admin_password

Input openstack_member_username
?  member_name

Input openstack_member_api_key(password)
?  member_password

Input openstack_member_current_tenant
?  service

Input openstack_member_ssh_keyname
?  ssh_key_name

I, [2013-09-18T18:55:58.279663 #1656]  INFO -- : ConfigFile created.
```

## Acceptance tests


### Compute API acceptance

`cucumber features/compute_api.feature`

#### Scnario and result

```
# coding: utf-8
Feature: OpenStack Compute API
  In order to provide services on OpenStack
  As a OpnStack user
  I want to control an infrastructure with remote api

  Background: We have own OpenStack environment.            # features/compute_api.feature:8
    Given I have an account which roled member of OpenStack # features/step_definitions/compute_api_steps.rb:4
    And My current tenant is available                      # features/step_definitions/compute_api_steps.rb:29

  Scenario: Verify available Nework                         # features/compute_api.feature:12
    Given I retrieve "Network" from API                     # features/step_definitions/compute_api_steps.rb:17
    Then There is at least one ACTIVE router                # features/step_definitions/compute_api_steps.rb:35
    And It has network "ext_net"                            # features/step_definitions/compute_api_steps.rb:41
    And It has network "int_net"                            # features/step_definitions/compute_api_steps.rb:41

  Scenario: Verify available Images                         # features/compute_api.feature:18
    Given I retrieve "Image" from API                       # features/step_definitions/compute_api_steps.rb:17
    Then There are at least one image                       # features/step_definitions/compute_api_steps.rb:46

  Scenario: Verify computer dependencies                    # features/compute_api.feature:22
    Given I retrieve "Compute" from API                     # features/step_definitions/compute_api_steps.rb:17
    Then There are at least one flavor                      # features/step_definitions/compute_api_steps.rb:51
    Then There are at least one keypair                     # features/step_definitions/compute_api_steps.rb:56

  Scenario: Create and destroy Computer                               # features/compute_api.feature:27
    Given I retrieve "Network" from API                               # features/step_definitions/compute_api_steps.rb:17
    Given I retrieve "Image" from API                                 # features/step_definitions/compute_api_steps.rb:17
    Given I retrieve "Compute" from API                               # features/step_definitions/compute_api_steps.rb:17
    When A requirement which must be satisfied before create computer # features/step_definitions/compute_api_steps.rb:61
    And I try to create computer with private nic                     # features/step_definitions/compute_api_steps.rb:71
    Then new computer should be ACTIVE                                # features/step_definitions/compute_api_steps.rb:86
    When I create floating_ip and associate to new computer           # features/step_definitions/compute_api_steps.rb:99
    Then computer has valid attributes                                # features/step_definitions/compute_api_steps.rb:112
    When I try to destroy new computer                                # features/step_definitions/compute_api_steps.rb:95
    And I release floating_ip                                         # features/step_definitions/compute_api_steps.rb:107

4 scenarios (4 passed)
27 steps (27 passed)
```


Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: sawanoboryu@higanworks.com (HiganWorks LLC)

Licensed under the MIT License;
