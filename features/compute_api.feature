# coding: utf-8

Feature: OpenStack Compute API
  In order to provide services on OpenStack
  As a OpnStack user
  I want to control an infrastructure with remote api

  Background: We have own OpenStack environment.
    Given I have an account which roled member of OpenStack
    And My current tenant is available

  Scenario: Verify available Nework
    Given I retrieve "Network" from API
    Then There is at least one ACTIVE router
    And It has network "ext_net"
    And It has network "int_net"

  Scenario: Verify available Images
    Given I retrieve "Image" from API
    Then There are at least one image

  Scenario: Verify computer dependencies
    Given I retrieve "Compute" from API
    Then There are at least one flavor
    Then There are at least one keypair

  Scenario: Create and destroy Computer
    Given I retrieve "Network" from API
    Given I retrieve "Image" from API
    Given I retrieve "Compute" from API
    When A requirement which must be satisfied before create computer
    And I try to create computer with private nic
    Then new computer should be ACTIVE
    When I create floating_ip and associate to new computer
    Then computer has valid attributes
    When I try to destroy new computer
    And  I release floating_ip

